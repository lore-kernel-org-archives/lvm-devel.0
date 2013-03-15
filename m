From: David Teigland <teigland@redhat.com>
Date: Fri, 15 Mar 2013 14:49:19 -0500
Subject: [PATCH 0/5] rework process each vg,lv
Message-ID: <1363376964-23100-1-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is the start of a number of patches to prepare the way for a new lvm
locking system.  The goal for now is to split up and simplify the command
processing so that I can eventually insert the new locking calls in the
correct places.

Next steps include:

- move process_each_vg,lv vg_read's into a new loop that is
  run before the loop to process each

- rework process_each_pv and the commands that use it so that
  it matches process_each_vg,lv

Dave


