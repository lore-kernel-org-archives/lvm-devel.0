From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Apr 2007 13:38:37 -0400
Subject: [PATCH 0/2] Add pvck ability to scan for labels on any area of disk
Message-ID: <1177090717.11574.4.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches add a little functionality to pvck, namely the ability to
scan for labels on any area of the disk, and report the labels found and
locations.

The first patch adds a parameter to label_read and _find_labeller, and
should not change functional behavior.  The second patch changes pvck to
utilize the new code and take a "--labelsector" parameter.


