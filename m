From: Jonathan Brassow <jbrassow@redhat.com>
Date: Fri, 30 Sep 2011 16:06:30 -0500
Subject: [PATCH 0 of 3] Patches to clean-up splitmirror code and fix bugs
Message-ID: <1317416791.4475.3.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The following three patches are intended to fix bug 733114 - "mirror
conversion and mirror image splitting results in device i/o errors".

The first patch reverts a work-around that failed to address the issue
in the cluster environment.

The second addresses improper udev_flag settings for sub-LVs.

The third is a clean-up of the splitmirrors code.

 brassow


