From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 23 Jun 2010 11:39:36 -0400
Subject: [PATCH 0/1] Only write metadata_copies to if explicitly set or read
Message-ID: <1277307577-20552-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


This patch only writes the new "metadata_copies" field in the vg metadata
if a new value is explicitly set, or the value was already in the
vg metadata.

Personally, I don't think this patch is necessary, given the fact that
previous versions of LVM don't parse fields they doesn't understand.
However I can add this patch to the previous metadata balance patch set
if others feel it is a requirement.


