%define version 0.1.18
%define release 1
%define name smeserver-fail2ban


Summary: fail2ban integration on SME Server
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
Epoch: 9
License: GPL
Group: Networking/Daemons
Source: %{name}-%{version}.tar.gz

BuildRoot: /var/tmp/%{name}-%{version}-%{release}-buildroot
BuildArchitectures: noarch
BuildRequires: e-smith-devtools

Requires: e-smith-base >= 5.2.0
Requires: fail2ban

%description
Configure fail2ban on SME Server

%changelog
* Fri Oct 27 2017 Daniel Berteaud <daniel@firewall-services.com> - 0.1.18-1.sme
- Ignore greylisting, from Michael McCarn [SME: 10447]

* Thu Nov 17 2016 Daniel Berteaud <daniel@firewall-services.com> - 0.1.17-1.sme
- Makes sur log files exist before resuming monitoring after a logrotate
  [SME: 9875]

* Tue Aug 2 2016 Daniel Berteaud <daniel@firewall-services.com> - 0.1.16-1.sme
- Add a new prop (FilterValidRemoteHosts) to allow blacklisting of hosts allowed
  to access the server-manager
- Ignore 0.0.0.0/0.0.0.0 by default [SME: 9719]

* Tue Jul 5 2016 Daniel Berteaud <daniel@firewall-services.com> - 0.1.15-1.sme
- Fix compat with older qpsmtpd

* Thu Jun 9 2016 Daniel Berteaud <daniel@firewall-services.com> - 0.1.14-1.sme
- Update regex for qpsmtpd 0.96

* Mon Feb 29 2016 Daniel Berteaud <daniel@firewall-services.com> - 0.1.13-1.sme
- Ignore failure to get proxy.pac

* Fri Jul 24 2015 Daniel Berteaud <daniel@firewall-services.com> - 0.1.12-1.sme
- Updates for fail2ban 0.9.2
- Add more httpd jails
- Switch to upstream Ejabberd filter

* Wed Apr 15 2015 Daniel Berteaud <daniel@firewall-services.com> - 0.1.11-1.sme
- Start fail2ban a bit later [SME: 8708]

* Tue Jan 27 2015 Daniel Berteaud <daniel@firewall-services.com> - 0.1.10-1.sme
- Suspend log monitoring during logrotate [SME: 8708]

* Thu Jan 15 2015 Daniel Berteaud <daniel@firewall-services.com> - 0.1.9-1.sme
- Fix LL::NG jail name

* Wed Sep 17 2014 Daniel Berteaud <daniel@firewall-services.com> - 0.1.8-1.sme
- Restart fail2ban during logrotate event so it re-open apache log file [SME: 8557]

* Wed Jun 25 2014 Daniel Berteaud <daniel@firewall-services.com> - 0.1.7-1.sme
- Correctly handle single IP in IgnoreIP prop

* Tue Jun 24 2014 Daniel Berteaud <daniel@firewall-services.com> - 0.1.6-1.sme
- Relax proxy regex so requests for proxy.pac aren't matched

* Mon Jun 23 2014 Daniel Berteaud <daniel@firewall-services.com> - 0.1.5-1.sme
- Pre-create the logfile so fail2ban can start the first time
- Remove most warnings on startup

* Wed Apr 23 2014 Daniel Berteaud <daniel@firewall-services.com> - 0.1.4-1.sme
- New branch for SME9
- Remove sogo-auth.conf which is included in EL6 build of fail2ban
>>>>>>> sme9

* Wed Dec 18 2013 Daniel Berteaud <daniel@firewall-services.com> - 0.1.3-1.sme
- Fix port, which was incorrectly set to proto

* Tue Nov 19 2013 Daniel Berteaud <daniel@firewall-services.com> - 0.1.2-1.sme
- Create the DB entries in one transaction to reduce the amount of log
  for each ban

* Thu Jul 4 2013 Daniel Berteaud <daniel@firewall-services.com> - 0.1.1-1.sme
- Fix service name for LemonLDAP::NG

* Tue May 14 2013 Daniel Berteaud <daniel@firewall-services.com> - 0.1.0-1.sme
- initial release

%prep
%setup -q -n %{name}-%{version}

%build
%{__mkdir_p} root/var/log/fail2ban
perl createlinks

%install
/bin/rm -rf $RPM_BUILD_ROOT
(cd root   ; /usr/bin/find . -depth -print | /bin/cpio -dump $RPM_BUILD_ROOT)
/bin/rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT \
   --dir /var/log/fail2ban 'attr(0750,root,root)' \
   --file /var/log/fail2ban/daemon.log 'config(noreplace) %attr(0600,root,root)' \
   --file /etc/cron.daily/cleanup_fail2ban 'attr(0755,root,root)' \
   --file /etc/fail2ban/filter.d/apache-auth.local 'config(noreplace) %attr(0644,root,root)' \
  > %{name}-%{version}-filelist

%files -f %{name}-%{version}-filelist
%defattr(-,root,root)

%clean
rm -rf $RPM_BUILD_ROOT

%post

%preun

