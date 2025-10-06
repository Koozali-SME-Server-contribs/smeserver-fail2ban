package SrvMngr::Controller::Fail2ban;

#----------------------------------------------------------------------
# heading     : Network
# description : Fail2Ban
# navigation  : 6000 800

# name : fail2ban,  method : get,  url : /fail2ban,   ctlact : fail2ban#main
# name : fail2banu, method : post, url : /fail2ban,   ctlact : fail2ban#do_action
# name : fail2banr, method : get,  url : /fail2ban2,  ctlact : fail2ban#do_action_get
#
# routes : end
#----------------------------------------------------------------------

use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';

use Locale::gettext;
use SrvMngr::I18N;

use Data::Validate::IP;

#use esmith::FormMagick::Panel::fail2ban;
#    qw( get_value get_prop change_settings RemoveIP );

use SrvMngr qw( theme_list init_session ip_number );

my $cdb;

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
        "smanager" => 'enabled',
);


sub main {

    my $c = shift;
    $c->app->log->info($c->log_req);
	$cdb = esmith::ConfigDB::UTF8->open() or die "Couldn't open ConfigDB::UTF8\n";

    my %f2b_datas = ();
    my $title = $c->l('f2b_FORM_TITLE');

    $f2b_datas{'status'} = get_prop('fail2ban', 'status');
    $f2b_datas{'filterlocalnetworks'} = get_prop('fail2ban', 'FilterLocalNetworks');
    $f2b_datas{'filtervalidremotehosts'} = get_prop('fail2ban', 'FilterValidRemoteHosts');
    $f2b_datas{'mail'} = get_prop('fail2ban', 'Mail');
    $f2b_datas{'bantime'} = get_prop('fail2ban', 'BanTime');
    $f2b_datas{'findtime'} = get_prop('fail2ban', 'FindTime');
    $f2b_datas{'maxretry'} = get_prop('fail2ban', 'MaxRetry');
    $f2b_datas{'wordpress'} = get_prop('fail2ban', 'wordpress');

    $f2b_datas{'sshd'} = get_prop('sshd', 'Fail2Ban');
    $f2b_datas{'qpsmtpd'} = get_prop('qpsmtpd', 'Fail2Ban');
    $f2b_datas{'dovecot'} = get_prop('dovecot', 'Fail2Ban');
    $f2b_datas{'httpd-e-smith'} = get_prop('httpd-e-smith', 'Fail2Ban');
    $f2b_datas{'ftp'} = get_prop('sshd', 'Fail2Ban');
    $f2b_datas{'lemonldap'} = get_prop('lemonldap', 'Fail2Ban');
    $f2b_datas{'ejabberd'} = get_prop('ejabberd', 'Fail2Ban');
    $f2b_datas{'sogod'} = get_prop('sogod', 'Fail2Ban');
    $f2b_datas{'smanager'} = get_prop('smanager', 'Fail2Ban');

    $c->stash( title => $title, f2b_datas => \%f2b_datas);
    $c->render('fail2ban');
};


sub do_action {

    my $c = shift;
    $c->app->log->info($c->log_req);
	$cdb = esmith::ConfigDB::UTF8->open() or die "Couldn't open ConfigDB::UTF8\n";

    my $rt = $c->current_route;

    my %f2b_datas = ();
    my $title = $c->l('f2b_FORM_TITLE');

    my ($res, $result) = '';

    $f2b_datas{status}	= $c->param('Status');
    my $action = ( $c->param('action') || '' );
    $f2b_datas{ip}	= $c->param('Ip');
    $f2b_datas{bits}	= $c->param('Bits');

    # controls
    $res = ip_number_or_blank( $c, $f2b_datas{ip} );
    $result .= $res . " <br>" if ( $res ne 'OK' );

    $res = subnet_mask_bit( $c, $f2b_datas{bit} );
    $result .= $res . " <br>" if ( $res ne 'OK' );

    $res = validate_network_and_mask( $c, $f2b_datas{ip}, $f2b_datas{bits} );
    $result .= $res . " <br>" if ( $res ne 'OK' );

    #$result .= 'Blocked for testing d_a ! No updates for now '; # if $action;

    $res = '';
    if ( ! $result ) {
        $res = $c->do_changes();
        $result .= $res unless $res eq 'OK';
        if ( ! $result ) { 
	    $result = $c->l('f2b_SUCCESS'); 
        }
    }

    $c->stash( title => $title, f2b_datas => \%f2b_datas );
    if ($res ne 'OK') {
	$c->stash( error => $result );
	return $c->render('fail2ban');
    }

    my $message = 'fail2ban updates DONE';
    $c->app->log->info($message);
    $c->flash( success => $result );
    #$c->flash( error => " No changes applied !!" );

    #return to 'fail2ban' route !!!
    $c->redirect_to('/fail2ban');

};


sub do_action_get {

    my $c = shift;
    $c->app->log->info($c->log_req);
	$cdb = esmith::ConfigDB::UTF8->open() or die "Couldn't open ConfigDB::UTF8\n";

    my ($res, $result) = '';

    # controls

    my $action = ($c->param('action') || '');
    $result .= $c->l('f2b_ERROR_UPDATING') . " action: $action <br>"
	unless ($action eq 'RemoveIP');

    my $ip = ($c->param('IP') || ''); 
    my $whitelist = ($c->param('Whitelist'))? 'true' : 'false';

    #check ip
    my $validator=Data::Validate::IP->new;
    $result .= $c->l('f2b_ERROR_STOPPING') . " IP: $ip <br>"
	unless ($validator->is_ipv4($ip));
    $ip = $validator->is_ipv4($ip);

    # validate and untaint jail
    my $jail = ($c->param('Jail') || '');
    # could be [a-zA-Z0-9_\-]
    $jail = $jail =~ /([a-zA-Z0-9_\-]+)/ ? $1 : undef; 
    $result .= $c->l('f2b_ERROR_UPDATING') . " jail: $jail <br>"
	unless $jail;

    #$result .= 'Blocked for testing d_a_g ! No updates for now '; # if $action;

    $res = '';
    if ( ! $result ) {
        $res = $c->RemoveIP( $ip, $whitelist, $jail );
        $result .= $res unless $res eq 'OK';
        if ( ! $result ) { 
	    if ($whitelist eq "true" ) {
	    $result = $c->l('f2b_SUCCESS_IP_WHITE')." : $ip";
	    } else {
	    $result = $c->l('f2b_SUCCESS_IP')." : $ip";
	    }
        }
    }

    if ($res ne 'OK') {
	$c->flash( error => $result );
    } else {
        my $message = "fail2ban removeip $ip DONE";
	$c->app->log->info($message);
	$c->flash( success => $result );
    }

    $c->redirect_to('/fail2ban');

};


sub do_changes {

    my $c = shift;
    my %conf;
	$cdb = esmith::ConfigDB::UTF8->open() or die "Couldn't open ConfigDB::UTF8\n";

    # Don't process the form unless we clicked the Save button. The event is
    # called even if we chose the Remove link or the Add link.

    my $ip = ($c->param ('Ip') || '');
    my $status = ($c->param ('Status') || 'status');
    my $FilterLocalNetworks = ($c->param ('FilterLocalNetworks') || "enabled");
    my $FilterValidRemoteHosts= ($c->param ('FilterValidRemoteHosts') || "enabled");
    my $Mail= ($c->param ("Mail") || "enabled");
    my $BanTime= ($c->param ("BanTime") || '1800');
    my $FindTime= ($c->param ("FindTime") || '900');
    my $MaxRetry= ($c->param ("MaxRetry") ||  '3');

    # those are stored in a different key dedicated to the service
    my %services;
    $services{'sshd'}= ($c->param ("Sshd") ||'enabled');
    $services{'qpsmtpd'}= ($c->param ("Qpsmtpd") ||'enabled');
    $services{'dovecot'}= ($c->param ("Dovecot") ||'enabled');
    $services{'httpd-e-smith'}= ($c->param ("Httpd-e-smith") ||'enabled');
    $services{'ftp'}= ($c->param ("Ftp") ||'enabled');
    $services{'lemonldap'}= ($c->param ("Lemonldap") ||'enabled');
    $services{'ejabberd'}= ($c->param ("Ejabberd" ) ||'enabled');
    $services{'sogod'}= ($c->param ("Sogod" ) ||'enabled');
    $services{'wordpress'}= ($c->param ("Wordpress") ||'enabled');
    $services{'smanager'}= ($c->param ("Smanager") ||'enabled');


    #------------------------------------------------------------
    # Looks good; go ahead and change the access.
    #------------------------------------------------------------

    my $rec = $cdb->get('fail2ban');
    if ($rec) {
    	$rec->set_prop('status', $status);
	# unless prop empty and value eq default
	$rec->set_prop('FilterLocalNetworks', $FilterLocalNetworks) 
	    unless ( ! $cdb->get_prop('fail2ban','FilterLocalNetworks') 
		&& $FilterLocalNetworks eq $defaultval{'FilterLocalNetworks'}  );
	$rec->set_prop('FilterValidRemoteHosts', $FilterValidRemoteHosts) 
	    unless ( ! $cdb->get_prop('fail2ban','FilterValidRemoteHosts') 
		&& $FilterValidRemoteHosts  eq $defaultval{'FilterValidRemoteHosts'}  );
	$rec->set_prop('Mail', $Mail)
	     unless ( ! $cdb->get_prop('fail2ban','Mail') && $Mail eq $defaultval{'Mail'}  );
	$rec->set_prop('BanTime', $BanTime) 
	    unless ( ! $cdb->get_prop('fail2ban','BanTime') && $BanTime eq $defaultval{'BanTime'}  );
        $rec->set_prop('FindTime', $FindTime) 
    	    unless ( ! $cdb->get_prop('fail2ban','FindTime') && $FindTime eq $defaultval{'FindTime'}  );
        $rec->set_prop('MaxRetry', $MaxRetry) 
    	    unless ( ! $cdb->get_prop('fail2ban','MaxRetry') && $MaxRetry eq $defaultval{'MaxRetry'}  );
    }
    # for the 9 services update unless key does not exist and property does not exist and value eq default
    foreach my $key (keys %services) {
        if ($key eq "wordpress") {
                $rec = $cdb->get('fail2ban');
                my $getprop = $cdb->get_prop('fail2ban',$key) || "";
                $rec->set_prop($key, $services{$key}  ) 
            	    unless ( ! $rec || (! $cdb->get_prop('fail2ban', $key) && $services{$key} eq $defaultval{$key} )  );
        } else {
                $rec = $cdb->get($key);
                my $getprop = $cdb->get_prop($key,'Fail2Ban') || "";
                $rec->set_prop('Fail2Ban', $services{$key}  ) 
            	    unless ( ! $rec || (! $cdb->get_prop($key,'Fail2Ban') && $services{$key} eq $defaultval{$key} )  );
        }
    }

# ?? this seems to prevent reload of service if we update something and remove or add an ip... ??
    $c->add_new_valid_from;
    $c->remove_valid_from;

    unless ( system( "/sbin/e-smith/signal-event", "fail2ban-update" ) == 0 ) {
	return $c->l('f2b_ERROR_UPDATING');
    }

    unless ( system( "/sbin/e-smith/signal-event", "fail2ban-conf" ) == 0 ) {
	return $c->l('f2b_ERROR_UPDATING');
    }

	$cdb = esmith::ConfigDB::UTF8->open() or die "Couldn't open ConfigDB::UTF8\n";
    if ( $rec->prop('status') eq 'disabled' ) {
        unless ( `/etc/init.d/fail2ban stop`  ) {
	    return $c->l('f2b_ERROR_STOPPING');
        }
    }

    return 'OK';
}


# RemoveIP after validation
sub RemoveIP {

    my ( $c, $ip, $whitelist, $jail ) = @_;

    unless ( system( "/usr/bin/fail2ban-client set $jail unbanip  $ip ".' >/dev/null 2>&1'  ) == 0 ) {
           return $c->l('f2b_ERROR_UPDATING');
    }

    if ($whitelist eq 'true' ) {
	# add $ip to whitelist for the current $jail
	warn "/sbin/e-smith/db configuration setprop fail2ban IgnoreIP  `/sbin/e-smith/db configuration getprop fail2ban IgnoreIP`,$ip/32";
	unless ( system( "/sbin/e-smith/db configuration setprop fail2ban  IgnoreIP  `/sbin/e-smith/db configuration getprop fail2ban IgnoreIP`,$ip/32 ".' >/dev/null 2>&1'  ) == 0 
	&& system( "/usr/bin/fail2ban-client reload ".' >/dev/null 2>&1'  ) == 0 
	) {
           return $c->l('f2b_ERROR_UPDATING_WHITE');
        }
    }

    return 'OK';

}


sub add_new_valid_from {

    my $c = shift;

    my $ip = $c->param('Ip');
    my $bits = $c->param('Bits');

    # do nothing if no ip was added
    return 1 unless ($ip);

    my $rec = $cdb->get('fail2ban');
    return $c->l('f2b_ERR_NO_RECORD') unless $rec;

    my $prop = $rec->prop('IgnoreIP') || '';

    my @vals = split /,/, $prop;
    return '' if (grep /^$ip\/$bits$/, @vals); # already have this entry

    if ($prop ne '') {
        $prop .= ",$ip/$bits";
    } else {
        $prop = "$ip/$bits";
    }

    $rec->set_prop('IgnoreIP', $prop);

    return 1;
}


sub remove_valid_from {

    my $c = shift;

    my @remove = @{$c->every_param('ValidFromRemove')};
    return 1 unless @remove;

    my @vals = @{$c->get_valid_from()};
    unless (@vals) {
        print STDERR "ERROR: unable to load IgnoreIP property from conf db\n";
        return undef;
    }

    #$c->app->log->debug("remo: " . $c->dumper(\@remove) .' vals: '. $c->dumper(\@vals));

    foreach my $entry (@remove) {
        @vals = (grep { $entry ne $_ } @vals);
    }

    my $prop = '';
    $prop = join(',', @vals) if @vals;

    $cdb->get('fail2ban')->set_prop('IgnoreIP', $prop);

    return 1;
}


sub ip_number_or_blank {

    my $c = shift;
    my $ip = shift;

    if (!defined($ip) || $ip eq "") {
        return 'OK';
    }
    $c->ip_number( $ip );
}


sub subnet_mask_bit {

    my ($c, $mask) = @_;

    my @allowed = (8,9,12,14,16,17,20,22,24,25,28,30,32);

    if ( !defined($mask) || $mask eq "" || grep( /^$mask$/, @allowed ) ) {
        return "OK";
    }
    return $c->l('f2b_INVALID_SUBNET_MASK');
}


sub validate_network_and_mask {

  my $c = shift;
  my $net = shift || "";
  my $mask = shift || "";

#  my $net = $c->param('Ip') || "";
  if ($net xor $mask) {
    return $c->l('f2b_ERR_INVALID_PARAMS');
  }

  return 'OK';
}


sub get_prop {

#    my $c   = shift;
    my $item = shift;
    my $prop = shift;
    my $value = $cdb->get_prop($item, $prop) || '';
    if ( $value eq "" && exists($defaultval{$prop})  && $item eq "fail2ban") {
	$value=$defaultval{$prop};
    } elsif ( $value eq "" && exists($defaultval{$item}) && $prop eq "Fail2Ban" && $item ne "fail2ban" ) {
        $value=$defaultval{$item};
    }

    return $value;
}


sub get_valid_from {

    my $c = shift;
    my @vals_sorted = ();

    my $rec = $cdb->get('fail2ban');
    if ( $rec ) {
        my @vals = (split ',', $rec->prop('IgnoreIP') // '');
   	 @vals_sorted = sort ip_sort @vals if @vals;
#	@vals_sorted = @vals;
    }

    return \@vals_sorted;
}


sub get_current_deny {

    my $c = shift;

    my @cdeny = `/usr/bin/sfail2ban`;

    return \@cdeny
}


sub ip_sort(@) {
    return esmith::util::IPquadToAddr($a) <=> esmith::util::IPquadToAddr($b);
}


1;