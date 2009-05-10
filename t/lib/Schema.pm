{
package
  Schema::Item;
  
use base 'DBIx::Class';

__PACKAGE__->load_components(qw(Core));

__PACKAGE__->table('item');

__PACKAGE__->add_columns(
  id => { data_type => 'integer' },
  name => { data_type => 'text' },
);

__PACKAGE__->set_primary_key('id');

__PACKAGE__->resultset_class('DBIx::Class::ResultSetX::Count');

}


{ 
package 
  Schema;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes('Item');

sub connect {
  my $class = shift;
  unlink('t/test.db') if(-e 't/test.db');
  my $schema = $class->next::method('dbi:SQLite::memory:');
  $schema->deploy;
  return $schema;
}

}

1;

