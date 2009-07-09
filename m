From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu,  9 Jul 2009 03:08:38 -0400
Subject: [PATCH 0/9]: take2 - Implement vg_create() and 4 required vg_set*() APIs
Message-ID: <1247123327-26141-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This is a second iteration of the vg_create() patchset sent earlier.
I believe all comments so far have been addressed and I've broken the
patches up a bit more.

Passes testsuite and applies cleanly on:
commit e6901382a6fc4bb2c6dcb263b77ebcf61316cdac
Author: Dave Wysochanski <dwysocha@redhat.com>
Date:   Thu Jul 9 05:40:59 2009 +0000

    Fix memory leak in vgsplit when re-reading the VG.


