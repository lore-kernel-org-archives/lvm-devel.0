From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:21:48 -0500
Subject: [PATCH 0/21] take2: liblvm initialization, attribute, and object handling
Message-ID: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This is an updated set of liblvm patches.  Changes since the last time:
- lvm_vg_open(): added write mode with an attempt at allowing vgid as well as
vgnames.  This clearly does not work in all cases currently but is a start.
- lvm_vg_get_attr_list(): moved into lvm_vg_open() - does make sense and solves
the memory problem with the report handle
- adds struct lib_context, containing struct cmd_context as well as errno.
- lvm_errno() and lvm_strerrno()


