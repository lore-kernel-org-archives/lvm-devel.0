From: David Teigland <teigland@redhat.com>
Date: Tue, 26 Mar 2013 16:09:20 -0500
Subject: [PATCH 0/8] rework process each vg,lv,pv
Message-ID: <1364332168-24676-1-git-send-email-teigland@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

These patches split up and simply the process_each functions
in preparation for adding new locking.

This includes new tests, which pass, for the commands that call
the process_each functions.  (I've had to comment out the pvresize
checks because of an apparent pre-existing bug.)


