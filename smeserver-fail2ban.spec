%define version 0.1.18
%define release 38
%define name smeserver-fail2ban

Summary: fail2ban integration on SME Server
Name: %{name}
Version: %{version}
Release: %{release}%{?dist}
Epoch: 9
License: GPL
Group: Networking/Daemons
Source: %{name}-%{version}.tar.xz

BuildRoot: /var/tmp/%{name}-%{version}-%{release}-buildroot
BuildArchitectures: noarch
BuildRequires: smeserver-devtools

Requires: smeserver-base >= 5.2.0
Requires: fail2ban-server, fail2ban-sendmail
Requires: perl-Data-Validate-IP
Obsoletes: fail2ban-firewalld, firewalld
AutoReqProv: no

%description
Configure fail2ban on SME Server

%changelog
* Tue Sep 30 2025 Jean-Philippe Pialasse <jpp@koozali.org> 0.1.18-38.sme
- fix typo for uqpsmtpd [SME: 13172]
- fix smanager filter [SME: 13206]

* Fri Sep 26 2025 Jean-Philippe Pialasse <jpp@koozali.org> 0.1.18-36.sme
- fix spec file [SME: 13172]
- fix 05IgnoreIP fragment [SME: 12453]
- whitelist wan ip [SME: 12199]
- create Fail2ban chain if missing on reloading firewall  [SME: 10786]
- update qpsmtpd logs path
- fix createlinks

* Tue Sep 23 2025 Brian Read <brianr@koozali.org> 0.1.18-35.sme
- Change $config to config in layout file(s) [SME: 13171]

* Sun Sep 08 2024 fix-e-smith-pkg.sh by Trevor Batley <trevor@batley.id.au> 0.1.18-34.sme
- Fix e-smith references in smeserver-fail2ban [SME: 12732]

* Sat Sep 07 2024 cvs2git.sh aka Brian Read <brianr@koozali.org> 0.1.18-33.sme
- Roll up patches and move to git repo [SME: 12338]

* Sat Sep 07 2024 BogusDateBot
- Eliminated rpmbuild "bogus date" warnings due to inconsistent weekday,
  by assuming the date is correct and changing the weekday.

* Thu Sep 05 2024 Terry Fage <terry@fage.id.au> 0.1.18-32.sme
- add local 2024-09-05.patch

* Fri Mar 01 2024 Brian Read <brianr@koozali.org> 0.1.18-31.sme
- Edit SM2 Menu entry to conform to new arrangements [SME: 12493]

* Fri Jul 29 2022 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-30.sme
- add to core backup [SME: 12008]
- add local 2022-07-30 patch

* Mon Jul 25 2022 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-28.sme
- revert previous patch, wrong package [SME: 12011]

* Fri Jul 22 2022 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-27.sme
- add to core backup [SME: 12011]

* Fri Jul 22 2022 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-26.sme
- apply locale patch 2022-07-22

* Fri Jan 07 2022 Brian Read <brianr@bjsystems.co.uk> 0.1.18-25.sme
- Add-class-to-div-for-AdminLTE [SME: 11837]

* Thu Dec 09 2021 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-24.sme
- fix adding removing whitelisted hosts [SME: 10819]
  moved config options to dedicated page
- removed apache-badbots.local, lot of false positives [SME: 10857]

* Wed Dec 08 2021 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-22.sme
- fix apache-badbots logfile definition [SME: 10857]
  add updated badbot list.

* Wed Dec 08 2021 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-21.sme
- update wordpress filters [SME: 11651]

* Wed Dec 08 2021 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-20.sme
- allow baning subnet [SME: 11650]

* Wed Oct 27 2021 John Crisp <jcrisp@safeandsoundit.co.uk> 0.1.18-19.sme
- Fix my versioning

* Wed Oct 27 2021 John Crisp <jcrisp@safeandsoundit.co.uk> 0.1.18-18.sme
- Add Requires for perl-Data-Validate-IP [SME: 11720]

* Sun Sep 12 2021 Terry Fage <terry.fage@gmail.com> 0.1.18-17.sme
- redo fix for typo qpsmtpd status [SME: 11636]

* Wed Sep 08 2021 Terry Fage <terry.fage@gmail.com> 0.1.18-16.sme
- Update locale 2021-09-08 patch

* Sun Aug 22 2021 Terry Fage <terry.fage@gmail.com> 0.1.18-15.sme
- Update locale 2021-08-21 patch

* Thu Jul 08 2021 Michel Begue <mab974@gmail.com> 0.1.18-14.sme
- Add fail2ban panel in smeserver-manager  [SME: 11636]
- add smanager jail and filter
- fix typo for qsmtpd status change
- add AutoReqProv so smeserver-manager is not required

* Mon May 31 2021 Jean-Philippe Pialasse <tests@pialasse.com> 0.1.18-13.sme
- fix requirements and avoid firewalld  [SME: 10949]

* Tue May 25 2021 Terry Fage <tfage@yahoo.com.au> 0.1.18-12.sme
- Server Fails to Start SME10 [SME: 11586]

* Mon Apr 19 2021 Brian Read <brianr@bjsystems.co.uk> 0.1.18-11.sme
- Initial import to SME10 [SME: 10949]
- Add -update event to createlinks.

* Wed Nov 27 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-10.sme
- fix wordpress template error [SME: 10839]
- rewrite rule for [SME: 9719]
- add configurable values for recidive jail [SME: 10370]

* Wed Oct 16 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-9.sme
- propagate configuration changes to fail2ban after submiting changes [SME: 10817]

* Wed Oct 16 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-8.sme
- fix blocked hosts list not displaying unless smeserver-denyhosts also installed [SME: 10814]

* Fri Jul 19 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-7.sme
- prevent fail2ban failure if sogo not installed while a backup restored db entries [SME: 9669]

* Mon Jun 03 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-6.sme
- fix incorrect permissions on sfail2ban [SME: 10775]

* Mon Jun 03 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-5.sme
- fix wordpress fragment error preventing jail.conf to be updated [SME: 10776]

* Tue May 14 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-4.sme
- fix missing sfail2ban exec [SME: 10775]
- Apply locals

* Tue Apr 09 2019 Jean-Philipe Pialasse <tests@pialasse.com> 0.1.18-3.sme
- add admin panel [SME: 10767]
- add wordpress jails and filters [SME: 9709]

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
   --file /usr/bin/sfail2ban 'attr(0755,root,root)' \
  > %{name}-%{version}-filelist
#--file /etc/fail2ban/filter.d/apache-badbots.local 'config(noreplace) %attr(0644,root,root)' \

%files -f %{name}-%{version}-filelist
%defattr(-,root,root)

%clean
rm -rf $RPM_BUILD_ROOT

%post

if (systemctl list-unit-files |grep smanager) then
  echo "Smanager restart in spec file"
  /sbin/e-smith/signal-event smanager-refresh;
fi


%preun
