From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Thu, 13 Jul 2023 19:32:10 +0000
Subject: [Git][lvmteam/lvm2][main] 9 commits: debug: fix sscanf type
Message-ID: <64b0513aba17d_28a2d78499b8@gitlab-sidekiq-low-urgency-cpu-bound-v2-db56db498-552g9.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
cb2d32bd by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
debug: fix sscanf type

Last commit c38b668fc3ead664a35130c1acec63518630d1dc was pushed
with type &#39;scanf&#39; instead of &#39;sscanf&#39; needed for buffer reading.
Interestingly this caused scanning from &#39;stdin&#39; descriptor and
thus failures in lvm shell usage.

- - - - -
64b28e08 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
lvchange: add log_error for failure path

When change of monitoring fails, ensure there is log_error() printed.

- - - - -
5ce236a6 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
gcc: correct signess comparation

Compare int to int and unsigned to unsigned...

- - - - -
f8712c6c by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
makefiles: remove autom4te.cache

For &#39;make distclean&#39; remove also autom4te.cache
(from autoreconf).

- - - - -
7171260b by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
makefiles: install lvmdbusd executable

Use a different mechanism to ensure, lvmdbudd is executable at
install destination.

- - - - -
ae512e20 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: skip test if daemon is running

Skip the test, to avoid making all test failed when there is
&#39;left&#39; daemon running.

- - - - -
2ecd290c by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: use conf=fdatasync

Since we write here in 1k blocksize - we can&#39;t use direct.

- - - - -
4ae2dde5 by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: update

Just drop debug log in case of error happenig later,
so we do not print uneeded info...

- - - - -
f24eb81d by Zdenek Kabelac at 2023-07-13T21:31:18+02:00
tests: improve LD_LIBRARY_PATH setting

Some linkers do need libdevmapper-event-lvm2.so.2.03,
so add also this symlink to the tests  /lib dir.
This fixes the need to use previous LD_LIBRARY_PATH complex
setting and now works with much shorter list.

- - - - -


30 changed files:

- Makefile.in
- daemons/cmirrord/functions.c
- daemons/lvmdbusd/Makefile.in
- daemons/lvmdbusd/lvm_shell_proxy.py.in
- daemons/lvmlockd/lvmlockd-core.c
- lib/activate/dev_manager.c
- lib/device/bcache-utils.c
- lib/device/dev-cache.c
- lib/device/dev-mpath.c
- lib/device/dev-type.c
- lib/device/dev-type.h
- lib/device/device.h
- lib/device/device_id.c
- lib/device/filesystem.c
- lib/device/parse_vpd.c
- lib/display/display.c
- lib/label/label.c
- lib/locking/lvmlockd.c
- lib/log/log.c
- lib/metadata/integrity_manip.c
- lib/metadata/metadata.c
- lib/metadata/vdo_manip.c
- lib/misc/lvm-signal.c
- lib/report/report.c
- make.tmpl.in
- test/lib/aux.sh
- test/lib/inittest.sh
- test/shell/lvextend-snapshot-dmeventd.sh
- test/shell/pvck-dump.sh
- tools/command.c


The diff was not included because it is too large.


View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6e3b51681f826073eaba6ff193e4cdd9714f338d...f24eb81dbea7d7324550f11f04e1dc5bc966500d

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/6e3b51681f826073eaba6ff193e4cdd9714f338d...f24eb81dbea7d7324550f11f04e1dc5bc966500d
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230713/30fe7c2b/attachment-0001.htm>
