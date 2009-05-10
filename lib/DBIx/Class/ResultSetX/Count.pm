package DBIx::Class::ResultSetX::Count;

# ABSTRACT: extends DBIx::Class::ResultSet with count related methods

use strict;
use warnings;

use base qw(DBIx::Class::ResultSet);

=pod

=head1 SYNOPSIS
 
    my $rs = $schema->resultset('XXX');
    
    $rs->count_or_create( {
        id => 1,
        name => 'B'
    } );

As ResultSet subclass in Schema pm:

    __PACKAGE__->load_namespaces(
        default_resultset_class => '+DBIx::Class::ResultSetX::Count'
    );

Or use base in ResultSet/XXX.pm

    use base 'DBIx::Class::ResultSetX::Count';

=head1 DESCRIPTION

To perform better, I usually prefer C<count> instead of C<find>

=head1 METHODS

=cut

sub count_or_create {
    my $self  = shift;
    my $hash  = ref $_[0] eq 'HASH' ? shift : {@_};
    my $cnt   = $self->count($hash);
    if ( $cnt ) {
        return 0;
    } else {
        $self->create($hash);
    }
}

=pod

=head2 count_or_create

=over 4

=item Arguments: \%vals

=item Return Value: 0 or $rowobject

=back


  my $cd = $schema->resultset('CD')->count_or_create( {
      artist => 'Massive Attack',
      title  => 'Mezzanine',
  } );

like L<find_or_create>. but it only returns $rowobject if the record is created, or else, $cd is 0 when the record is already there.

=cut

sub count_for_update_or_create {

}

1;