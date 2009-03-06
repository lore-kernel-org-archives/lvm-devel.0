From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  6 Mar 2009 03:49:12 -0500
Subject: [PATCH 0/2]: Rename old liblvm and add new liblvm application library
Message-ID: <1236329354-26253-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following two patches rename the original LVM library, liblvm.a to
liblvm-internal.a which allows for the new application library.
The new application library is build in new subdirectory liblvm.



