package DBIx::Class::ResultSet::Void;

# ABSTRACT: improve DBIx::Class::ResultSet with void context

use strict;
use warnings;
use Carp::Clan qw/^DBIx::Class/;

use base qw(DBIx::Class::ResultSet);

=pod

=head1 SYNOPSIS
 
    my $rs = $schema->resultset('CD');
    $rs->find_or_create( {
        artist => 'Massive Attack',
        title  => 'Mezzanine',
    } );

As ResultSet subclass in Schema pm:

    __PACKAGE__->load_namespaces(
        default_resultset_class => '+DBIx::Class::ResultSet::Void'
    );

Or use base in ResultSet/XXX.pm

    use base 'DBIx::Class::ResultSet::Void';

=head1 DESCRIPTION

unless defined wantarray

=head1 METHODS

=cut

sub find_or_create {
  my $self     = shift;
  
  if ( defined wantarray ) {
    return $self->next::method(@_);
  }
  
  my $attrs    = (@_ > 1 && ref $_[$#_] eq 'HASH' ? pop(@_) : {});
  my $hash     = ref $_[0] eq 'HASH' ? shift : {@_};
  
  my $query  = $self->___get_primary_or_unique_key($hash, $attrs);
  my $exists = $self->count($query);
  $self->create($hash) unless $exists;
}

sub update_or_create {
  my $self = shift;
  
  if ( defined wantarray ) {
    return $self->next::method(@_);
  }
  
  my $attrs = (@_ > 1 && ref $_[$#_] eq 'HASH' ? pop(@_) : {});
  my $cond = ref $_[0] eq 'HASH' ? shift : {@_};

  my $query  = $self->___get_primary_or_unique_key($cond, $attrs);
  my $exists = $self->count($query);

  if ( $exists ) {
    $self->search($query)->update($cond);
  } else {
    $self->create($cond);
  }
}

# mostly copied from sub find
sub ___get_primary_or_unique_key {
  my $self = shift;
  my $attrs = (@_ > 1 && ref $_[$#_] eq 'HASH' ? pop(@_) : {});
    
  # Default to the primary key, but allow a specific key
  my @cols = exists $attrs->{key}
    ? $self->result_source->unique_constraint_columns($attrs->{key})
    : $self->result_source->primary_columns;
  $self->throw_exception(
    "Can't find unless a primary key is defined or unique constraint is specified"
  ) unless @cols;

  # Parse out a hashref from input
  my $input_query;
  if (ref $_[0] eq 'HASH') {
    $input_query = { %{$_[0]} };
  }
  elsif (@_ == @cols) {
    $input_query = {};
    @{$input_query}{@cols} = @_;
  }
  else {
    # Compatibility: Allow e.g. find(id => $value)
    carp "Find by key => value deprecated; please use a hashref instead";
    $input_query = {@_};
  }

  my (%related, $info);

  KEY: foreach my $key (keys %$input_query) {
    if (ref($input_query->{$key})
        && ($info = $self->result_source->relationship_info($key))) {
      my $val = delete $input_query->{$key};
      next KEY if (ref($val) eq 'ARRAY'); # has_many for multi_create
      my $rel_q = $self->result_source->resolve_condition(
                    $info->{cond}, $val, $key
                  );
      die "Can't handle OR join condition in find" if ref($rel_q) eq 'ARRAY';
      @related{keys %$rel_q} = values %$rel_q;
    }
  }
  if (my @keys = keys %related) {
    @{$input_query}{@keys} = values %related;
  }


  # Build the final query: Default to the disjunction of the unique queries,
  # but allow the input query in case the ResultSet defines the query or the
  # user is abusing find
  my $alias = exists $attrs->{alias} ? $attrs->{alias} : $self->{attrs}{alias};
  my $query;
  if (exists $attrs->{key}) {
    my @unique_cols = $self->result_source->unique_constraint_columns($attrs->{key});
    my $unique_query = $self->_build_unique_query($input_query, \@unique_cols);
    $query = $self->_add_alias($unique_query, $alias);
  }
  else {
    my @unique_queries = $self->_unique_queries($input_query, $attrs);
    $query = @unique_queries
      ? [ map { $self->_add_alias($_, $alias) } @unique_queries ]
      : $self->_add_alias($input_query, $alias);
  }

  return $query;
}

1;