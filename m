From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 16 Feb 2009 21:55:14 -0500
Subject: [PATCH 0/3] Test case for demonstrating lvmcache bug with duplicate vgnames
In-Reply-To: <20090216190806.GA26197@agk.fab.redhat.com>
References: <20090216190806.GA26197@agk.fab.redhat.com>
Message-ID: <1234839317-20159-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 3 patches should apply cleanly and demonstrate the lvmcache bug.
The first patch just adds a couple accessor functions to display vgname and uuid.
The second patch is the fix for the bug.
The last patch contains the test code that demonstrates the bug.
Applying the first and third patches you should see the bug.  Then apply the 
second patch and rebuild and you should see the bug is removed.


