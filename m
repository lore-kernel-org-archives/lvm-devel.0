From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 27 May 2009 11:44:19 -0400 (EDT)
Subject: the new commandline interface
Message-ID: <Pine.LNX.4.64.0905271139590.28902@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I put the new interface here:

http://sources.redhat.com/lvm2/wiki/FeatureRequests/dm/snapshots

Besides what we talked about, I also propose aliasing --virtualsize to -L 
for all non-snapshot volumes. Both these arguments will do the same thing 
if not operating on a snapshot.

The reason is that the same commands should be used if the user runs 
lvresize script on a snapshot or non-snapshot volume --- so that the virt 
team can write single scripts that can manage machines on both snapshot 
and linear volumes.

Mikulas


