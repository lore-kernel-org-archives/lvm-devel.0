From: ben <benscott@nwlink.com>
Date: Sat, 7 Aug 2010 23:03:34 -0700
Subject: Can't delete "open" snapshots
Message-ID: <201008072303.34522.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Someone recently noted here that they have been having trouble deleting 
snapshots. I have been seeing the same behaviour with that latest CVS builds. 
I can create a snap, run "lvs", then try to delete the snapshot. Sometimes it 
will delete but more often lvremove complains the snap is "open" and refuses. 
If I rerun lvremove it will usually work eventually if I try several times. 
Oddly, running "lvs" after creating the snap seems to make it harder to 
delete.

Thank you.


