From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 14 May 2008 16:28:09 -0400 (EDT)
Subject: Deactivating volume with mounted snapshot
Message-ID: <Pine.LNX.4.64.0805141624070.380@engineering.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

When you type
lvchange -ay volume, it activates the volume and all its snapshots

Now you mount one of the snapshots. And then, type:
lvchange -an volume

--- the result is, that the volume and all the snapshots except the 
mounted one are deactivated. The mounted snapshot is still active.

It looks like a bug to me --- it was never indented to have some snapshots 
active and some not. With snapshot merging, this would cause data 
corruption on inactive snapshots (because they won't allocate new 
exceptions). Is it OK to disable this condition?

Mikulas


