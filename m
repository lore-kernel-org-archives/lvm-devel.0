From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 11 Mar 2016 00:24:14 +0000 (UTC)
Subject: v2_02_146 annotated tag has been created
Message-ID: <20160311002414.5DACB60D6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eddd448869573ca03e49c009e80cd4440fb0193f
Commit:        eddd448869573ca03e49c009e80cd4440fb0193f
Parent:        0000000000000000000000000000000000000000
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    2016-03-11 00:19 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: 2016-03-11 00:19 +0000

annotated tag: v2_02_146 has been created
	    at eddd448869573ca03e49c009e80cd4440fb0193f (tag)
       tagging 2159a1429d65adb824e67a1577625663d910516e (commit)
      replaces v2_02_145

Release 2.02.146.

Another development checkpoint - all recent API changes are still not frozen.

67 files changed, 985 insertions(+), 365 deletions(-)
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEABECAAYFAlbiDyAACgkQIoGRwVZ+LBcntwCg804fiwvLyCirQp1bAu/L6zNj
9OoAn25XIxRQzSELiLobHEHRrG68QCBC
=LtBU
-----END PGP SIGNATURE-----

Alasdair G Kergon (3):
      post-release
      report: Tidy some field names, widths and headings.
      pre-release

David Teigland (6):
      dbus: add notification from commands
      vgscan: add --notifydbus to send a notification
      toollib: always process in use pvs
      remove unused define
      pvchange, pvresize: move exported VG check
      man: vgcreate shared

Heinz Mauelshagen (1):
      raid_manip: allow for raid leg to be replaced when not both data and metadata image are on pvs

Marian Csontos (7):
      test: Update kernels to skip thin-flags with
      test: Move udev-lvmlockd-test to check_system
      test: Comment out incorrect lockd setup
      spec: Add missing dependency for dbusd
      test: Add prepare_lvmdbusd
      spec: Fix gobject dependency
      test: Remove work-in-progress code from dbustest

Ondrej Kozina (2):
      test: fix inverted condition
      test: skip unrelated tests while testing lvmpolld

Peter Rajnoha (2):
      coverity: fix possible resource leak in _print_historical_lv function
      metadata: do not issue warning message about PV dev size being 0 when the device has gone just after VG read

Tony Asleson (2):
      lvmdbus: Fix exception during exception handling
      lvmdbus:  Fix deprecated warnings for GObject use

Zdenek Kabelac (14):
      libdm: parse more info from cache status
      lvconvert: uncache handles missing PV
      cache: check for cache fail during flush
      lvconvert: improve vg parameter parsing
      makefiles: avoid using vpath for rules files
      man: updates
      man: drop extra braces
      topology: handle reported sizes smaller then sector
      gcc: cast time_t to 64bit
      cleanup: add backtrace
      cleanup: reoder lines
      cleanup: display_lvname
      tests: uncache with missing PV
      lvconvert: update --help


