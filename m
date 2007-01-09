From: Bryn M. Reeves <breeves@redhat.com>
Date: Tue, 09 Jan 2007 21:49:35 +0000
Subject: [LVM2 PATCH] cleanup configure output
Message-ID: <45A40DEF.4080306@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi Alasdair,

Three of the LVM2 configure tests produce duplicated results:

checking for sepol_check_context function... checking for
sepol_check_context in -lsepol... no
no
checking for is_selinux_enabled function... checking for
is_selinux_enabled in -lselinux... yes
yes
checking for clock_gettime function... checking for clock_gettime in
- -lrt... yes
yes

These are AC_CHECK_LIB tests followed by an AC_MSG_RESULT, but
AC_CHECK_LIB already outputs the result by itself.

Attached patch removes the redundant AC_MSG_RESULT macros.

Regards,

Bryn.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFFpA3v6YSQoMYUY94RAsK8AJ9X4pGXgDBa7IeSrGtqZcMC7/zQ/gCeIunM
mL1qWdsFS2UE+jqhzPODplc=
=jImi
-----END PGP SIGNATURE-----
-------------- next part --------------
A non-text attachment was scrubbed...
Name: drop-redundant-autoconf-messages.patch
Type: text/x-patch
Size: 1173 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070109/9bd85573/attachment.bin>
