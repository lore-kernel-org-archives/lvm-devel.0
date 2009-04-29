From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 15:55:26 -0400
Subject: [PATCH 0/8]: liblvm object attribute baseline
Message-ID: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following 8 patches implement a baseline for liblvm objects and their
attributes.  The primary focus/goal of these patches are:
1. Define / clarify the main liblvm objects and their handles
2. Get the object properties for a specific handle

Together with the handles, the 'get' functions will provide equivalent
functionality to the reporting commands (pvs, vgs, lvs) while keeping with
the object model of liblvm.



