From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:21:02 -0600
Subject: [PATCH 0 of 10] LVM: mirrored/redundant/duplicate mirror log
Message-ID: <1263954062.22044.9.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I found a bug in the previous patches that were disrupting the workings
of 'lvconvert --repair'.  I was not properly grabbing the first item of
a list (and checking for NULL).

I am also having some mysterious trouble running the testsuite.  I am
getting different results between identical runs.  I'm not sure if I
have some old dmeventd running or what...

Also, people are unhappy with "redundant" as the name of the log type.
Other suggestions?  "mirrored"?  "duplicated"?

 brassow



