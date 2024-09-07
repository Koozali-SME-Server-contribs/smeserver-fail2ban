#!/usr/bin/perl -w

package    esmith::FormMagick::Panel::fail2ban;

use strict;
use esmith::ConfigDB;
use esmith::FormMagick;
use esmith::util;
use esmith::cgi;
use File::Basename;
use Exporter;
use Carp;
use Data::Validate::IP;

our @ISA = qw(esmith::FormMagick Exporter);

our @EXPORT = qw(get_value get_prop change_settings RemoveIP add_new_valid_from);

our $VERSION = sprintf '%d.%03d', q$Revision: 1.1 $ =~ /: (\d+).(\d+)/;
our $db = esmith::ConfigDB->open
    || warn "Couldn't open configuration database (permissions problems?)";
my $scriptname = basename($0);

#TODO 
#- translation
#- userpanel without settings

my %defaultval=('FilterLocalNetworks'=> "enabled",
	'FilterValidRemoteHosts'=> "enabled",
	"Mail" => "enabled",
        "BanTime" => '1800',
        "FindTime" => '900',
        "MaxRetry" =>  '3',
        "sshd" => 'enabled',
        "qpsmtpd" => 'enabled',
        "dovecot" => 'enabled',
	"httpd-e-smith" => 'enabled',
        "ftp" => 'enabled',
	"lemonldap" => 'enabled',
        "ejabberd"  => 'enabled',
        "sogod"  => 'disabled',
        "wordpress" => 'disabled',
         
 ) ;

sub new {
    shift;
    my $self = esmith::FormMagick->new();
    $self->{calling_package} = (caller)[0];
    bless $self;
    return $self;
}

sub get_prop
{
    my $fm   = shift;
    my $item = shift;
    my $prop = shift;
    my $value = $db->get_prop($item, $prop) || '';
    if ( $value eq "" && exists($defaultval{$prop})  && $item eq "fail2ban")
	{
		$value=$defaultval{$prop};
	}
    elsif ( $value eq "" && exists($defaultval{$item}) && $prop eq "Fail2Ban" && $item ne "fail2ban" )
        {
                $value=$defaultval{$item};
        }
    return $value;
}

sub get_value {
    my $fm = shift;
    my $item = shift;
    return ($db->get($item)->value());
}

sub ip_number_or_blank
{
    my $self = shift;
    my $ip = shift;

    if (!defined($ip) || $ip eq "")
    {
        return 'OK';
    }
    return CGI::FormMagick::Validator::ip_number($self, $ip);
}

sub subnet_mask_bit 
{
    my ($self, $mask) = @_;
    my @allowed = (8,9,12,14,16,17,20,22,24,25,28,30,32);
#    if ($self->ip_number_or_blank($mask) eq 'OK')
    if ( !defined($mask) || $mask eq "" || grep( /^$mask$/, @allowed ) )
    {
        return "OK";
    }
    return "INVALID_SUBNET_MASK";
}

sub validate_network_and_mask
{
  my $self = shift;
  my $mask = shift || "";

  my $net = $self->cgi->param('ip') || "";
  if ($net xor $mask)
  {
    return $self->localise('ERR_INVALID_PARAMS');
  }
  return 'OK';
}



sub _get_valid_from
{
    my $self = shift;

    my $rec = $db->get('fail2ban');
    return undef unless($rec);
    my @vals = (split ',', ($rec->prop('IgnoreIP') || ''));
    return @vals;
}

sub ip_sort(@)
{
    return esmith::util::IPquadToAddr($a) <=> esmith::util::IPquadToAddr($b);
}

sub show_config_link
{
    my $self = shift;
    my $q = $self->{cgi};

    print '<tr><td colspan=2>',"<a href=\"$scriptname?page=0&page_stack=&Next=Next&wherenext=Config\">",
	$q->p($self->localise('CONFIG')),'</a></td></tr>';
    return '';
}

sub show_valid_from_list
{
    my $self = shift;
    my $q = $self->{cgi};

    print '<tr><td colspan=2>',$q->p($self->localise('VALIDFROM_DESC')),'</td></tr>';

    my @vals = $self->_get_valid_from();
    if (@vals)
    {
        print '<tr><td colspan=2>',
              $q->start_table({class => "sme-border"}),"\n";
        print $q->Tr(
                esmith::cgi::genSmallCell($q, $self->localise('NETWORK'),"header"),
                esmith::cgi::genSmallCell($q, $self->localise('REMOVE'),"header"));
	my @vals_sorted= sort ip_sort @vals;
        my @cbGroup = $q->checkbox_group(-name => 'validFromRemove',
                -values => [@vals_sorted], -labels => { map {$_ => ''} @vals_sorted });
        foreach my $val (@vals_sorted)
        {
            print $q->Tr(
                    esmith::cgi::genSmallCell($q, $val, "normal"),
                    esmith::cgi::genSmallCell($q, shift(@cbGroup),
                        "normal"));
        }
        print '</table></td></tr>';
    }
    else
    {
        print $q->Tr($q->td($q->b($self->localise('NO_ENTRIES_YET'))));
    }
    return '';
}

sub show_current_deny
{
    my $self = shift;
    my $q = $self->{cgi};

    print '<tr><td colspan=2>',$q->p($self->localise('CURRENT_DENY_DESC')),'</td></tr>';

    my @strvals = `/usr/bin/sfail2ban`;
    
    if (@strvals)
    {
        print '<tr><td colspan=2>',
              $q->start_table({class => "sme-border"}),"\n";
        print $q->Tr(
                esmith::cgi::genSmallCell($q, $self->localise('IP_ADDRESS'),"header"),
                esmith::cgi::genSmallCell($q, $self->localise('JAIL'),"header"),
		esmith::cgi::genSmallCell($q, $self->localise('ACTION'),"header"));
	foreach my $sval (@strvals)
	{
	    my @ssval= split(':',$sval);
	    my $curjail=$ssval[0];
	    my @ssvalip = split(' ',$ssval[1]);
	    foreach my $sssval (@ssvalip)
	    {
	    my $ip=$sssval;
            my $action3 ="<a href=\"$scriptname?page=0&page_stack=&Next=Next&action=RemoveIP&IP=$ip&jail=$curjail&wherenext=Second\">".$self->localise('REMOVE')."</a>" .
                          " <a href=\"$scriptname?page=0&page_stack=&Next=Next&action=RemoveIP&IP=$ip&jail=$curjail&wherenext=Second&Whitelist=true\">".$self->localise('WHITELIST')."</a>" ;
 
            	print $q->Tr(
                    esmith::cgi::genSmallCell($q, $ip, "normal"),
                    esmith::cgi::genSmallCell($q, $curjail, "normal"),
                    esmith::cgi::genSmallCell($q, $action3, "normal"));
	    }


	}
        print '</table></td></tr>';
    }
    else
    {
        print $q->Tr($q->td($q->b($self->localise('NO_ENTRIES_YET'))));
    }
    return '';
}

sub add_new_valid_from
{
    my $self = shift;
    my $q = $self->{cgi};

    my $ip = $q->param('ip');
    my $bits = $q->param('bits');
    # do nothing if no ip was added
    return 1 unless ($ip);

    my $rec = $db->get('fail2ban');
    unless ($rec)
    {
        return $self->error('ERR_NO_RECORD');
    }

    my $prop = $rec->prop('IgnoreIP') || '';

    my @vals = split /,/, $prop;
    return $self->error('ERR_EXISTS') if (grep /^$ip\/$bits$/, @vals); # already have this entry

        if ($prop ne '')
        {
            $prop .= ",$ip/$bits";
        }
        else
        {
            $prop = "$ip/$bits";
        }
    $rec->set_prop('IgnoreIP', $prop);
    $q->delete('ip');
    $q->delete('bits');
    return 1
}

sub remove_valid_from
{
    my $self = shift;
    my $q = $self->{cgi};

    my @remove = $q->param('validFromRemove');
    my @vals = $self->_get_valid_from();

    foreach my $entry (@remove)
    {
        return undef unless $entry;

        unless (@vals)
        {
            print STDERR "ERROR: unable to load IgnoreIP property from conf db\n";
            return undef;
        }

        @vals = (grep { $entry ne $_ } @vals);
    }

    my $prop;
    if (@vals)
    {
        $prop = join ',',@vals;
    }
    else
    {
        $prop = '';
    }
    $db->get('fail2ban')->set_prop('IgnoreIP', $prop);
    $q->delete('validFromRemove');

    return 1;
}

sub change_whitelist {
    my ($fm) = @_;
    my $q = $fm->{'cgi'};

    my %conf;

    # Don't process the form unless we clicked the Save button. The event is
    # called even if we chose the Remove link or the Add link.
    return unless($q->param('Next') eq $fm->localise('SAVE'));
    my $ip = ($q->param ('ip') || '');
    return '' unless $fm->add_new_valid_from;
    return '' unless $fm->remove_valid_from;

    unless ( system( "/sbin/e-smith/signal-event", "fail2ban-conf" ) == 0 )
    {
        $fm->error('ERROR_UPDATING');
        return undef;
    }

    $fm->success('SUCCESS');
}

sub change_settings {
    my ($fm) = @_;
    my $q = $fm->{'cgi'};

    my %conf;

    # Don't process the form unless we clicked the Save button. The event is
    # called even if we chose the Remove link or the Add link.
    return unless($q->param('Next') eq $fm->localise('SAVE'));

    my $ip = ($q->param ('ip') || '');
    my $status = ($q->param ('status') || 'status');
    my $FilterLocalNetworks = ($q->param ('FilterLocalNetworks') || "enabled");
    my $FilterValidRemoteHosts= ($q->param ('FilterValidRemoteHosts') || "enabled");
    my $Mail= ($q->param ("Mail") || "enabled");
    my $BanTime= ($q->param ("BanTime") || '1800');
    my $FindTime= ($q->param ("FindTime") || '900');
    my $MaxRetry= ($q->param ("MaxRetry") ||  '3');
    # those are stored in a different key dedicated to the service
    my %services;
    $services{'sshd'}= ($q->param ("sshd") ||'enabled');
    $services{'qpsmtpd'}= ($q->param ("qpsmtpd") ||'enabled');
    $services{'dovecot'}= ($q->param ("dovecot") ||'enabled');
    $services{'httpd-e-smith'}= ($q->param ("httpd-e-smith") ||'enabled');
    $services{'ftp'}= ($q->param ("ftp") ||'enabled');
    $services{'lemonldap'}= ($q->param ("lemonldap") ||'enabled');
    $services{'ejabberd'}= ($q->param ("ejabberd" ) ||'enabled');
    $services{'sogod'}= ($q->param ("sogod" ) ||'enabled');
    $services{'wordpress'}= ($q->param ("wordpress") ||'enabled');


    #------------------------------------------------------------
    # Looks good; go ahead and change the access.
    #------------------------------------------------------------

    my $rec = $db->get('fail2ban');
    if ($rec)
    {
    	$rec->set_prop('status', $status);
	# unless prop empty and value eq default
	$rec->set_prop('FilterLocalNetworks', $FilterLocalNetworks) unless ( ! $db->get_prop('fail2ban','FilterLocalNetworks') && $FilterLocalNetworks eq $defaultval{'FilterLocalNetworks'}  );
	$rec->set_prop('FilterValidRemoteHosts', $FilterValidRemoteHosts) unless ( ! $db->get_prop('fail2ban','FilterValidRemoteHosts') && $FilterValidRemoteHosts  eq $defaultval{'FilterValidRemoteHosts'}  );
	$rec->set_prop('Mail', $Mail) unless ( ! $db->get_prop('fail2ban','Mail') && $Mail eq $defaultval{'Mail'}  );
	$rec->set_prop('BanTime', $BanTime) unless ( ! $db->get_prop('fail2ban','BanTime') && $BanTime eq $defaultval{'BanTime'}  );
        $rec->set_prop('FindTime', $FindTime) unless ( ! $db->get_prop('fail2ban','FindTime') && $FindTime eq $defaultval{'FindTime'}  );
        $rec->set_prop('MaxRetry', $MaxRetry) unless ( ! $db->get_prop('fail2ban','MaxRetry') && $MaxRetry eq $defaultval{'MaxRetry'}  );
    }
    # for the 9 services update unless key does not exist and property does not exist and value eq default
	foreach my $key (keys %services)
    {
        if ($key eq "wordpress")
        {
                $rec = $db->get('fail2ban');
                my $getprop = $db->get_prop('fail2ban',$key) || "";
                $rec->set_prop($key, $services{$key}  ) unless ( ! $rec || (! $db->get_prop('fail2ban', $key) && $services{$key} eq $defaultval{$key} )  );
        }
        else
        {
                $rec = $db->get($key);
                my $getprop = $db->get_prop($key,'Fail2Ban') || "";
                $rec->set_prop('Fail2Ban', $services{$key}  ) unless ( ! $rec || (! $db->get_prop($key,'Fail2Ban') && $services{$key} eq $defaultval{$key} )  );
        }
    }
# this seems to prevent reload of service if we update something and remove or add an ip...
#    return '' unless $fm->add_new_valid_from;
#    return '' unless $fm->remove_valid_from;
    
    unless ( system( "/sbin/e-smith/signal-event", "fail2ban-update" ) == 0 )
    {
	$fm->error('ERROR_UPDATING');
	return undef;
    }

    unless ( system( "/sbin/e-smith/signal-event", "fail2ban-conf" ) == 0 )
    {
        $fm->error('ERROR_UPDATING');
        return undef;
    }
	
    if ( $rec->prop('status') eq 'disabled' )
    {
        unless ( `/usr/bin/systemctl stop fail2ban`  )
        {
            $fm->error('ERROR_STOPPING');
            return undef;
        }
    }
    
    $fm->success('SUCCESS');
}

# validate subnet



# RemoveIP after validation
sub RemoveIP {
    my $fm = shift;
    my $q = $fm->{'cgi'};
    my %conf;
    my $ip = ($q->param('IP') || ''); 
    my $whitelist = ($q->param('Whitelist'))? "true" : '';
    #check ip
    my $validator=Data::Validate::IP->new;

    unless ($validator->is_ipv4($ip))
      	{
	   $fm->error('ERROR_STOPPING');
	   return undef;
	}
    $ip = $validator->is_ipv4($ip);
    # validate and untaint jail
    my $jail = ($q->param('jail') || '');
    # could be [a-zA-Z0-9_\-]
    $jail = $jail =~ /([a-zA-Z0-9_\-]+)/ ? $1 : undef; 
	$fm->error('ERROR_UPDATING') unless $jail;
	return undef unless $jail;
    unless ( system( "/usr/bin/fail2ban-client set $jail unbanip  $ip ".' >/dev/null 2>&1'  ) == 0 )
    	{
           $fm->error('ERROR_UPDATING');
           return undef;
    	}
    if ($whitelist ne "" ) {
	# add $ip to whitelist for the current $jail
	warn "/sbin/e-smith/db configuration setprop fail2ban IgnoreIP  `/sbin/e-smith/db configuration getprop fail2ban IgnoreIP`,$ip/32";
	unless ( system( "/sbin/e-smith/db configuration setprop fail2ban  IgnoreIP  `/sbin/e-smith/db configuration getprop fail2ban IgnoreIP`,$ip/32 ".' >/dev/null 2>&1'  ) == 0 
	&& system( "/usr/bin/fail2ban-client reload ".' >/dev/null 2>&1'  ) == 0 
	)
        {
           $fm->error('ERROR_UPDATING_WHITE');
           return undef;
        }
	
    	$fm->success($fm->localise('SUCCESS_IP_WHITE').": $ip",'First');
    }
    else
    {
        $fm->success($fm->localise('SUCCESS_IP').": $ip",'First');
    }
}

sub back {
    my $fm = shift;
    my $q = $fm->{'cgi'};
    print "<a href='$scriptname'>".$fm->localise('Back')."</a>";
return;
}

1;
