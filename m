From: Eric Wheeler <lvm-devel@lists.ewheeler.net>
Date: Fri, 4 Sep 2020 20:00:47 +0000 (UTC)
Subject: Regression: 9e20465fd1f71 [thin-repair, thin_dump] When repairing we now hunt for the best btree roots.
Message-ID: <alpine.LRH.2.11.2009041949440.19705@mail.ewheeler.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Joe,

It used to be that flags.opts was passed into metadata_dump even when 
--repair was specified. Now that metadata_dump and metadata_repair are 
split into different functions, flags.opts is not passed to 
metadata_repair so options like --dev-id are ignored when --repair is 
specified.

Looking at the difference in metadata_dump and metadata_repair, these 
functions are basically the same except the superblock recognition and 
mapping/details_damage_policy(true) which used to be handled by 
opts.repair_ (instead of true/false).

What do you think about reducing the code duplication in metadata_repair 
and metadata_dump by factoring out the common code into a function like 
_metadata_dump and then always passing in flags.opts?

We would like to retain the ability to run a repair on a metadata snapshot 
for a single dev_id. At the moment we used a customer emitter 
(contrib/ewheeler_emitter.cc) which works fine on metadata snapshots 
without --repair enabled, but when --repair is enabled we get metadata for 
every volume in the tree which ends up being huge (and invalid) because we 
have so many snapshots.

-Eric

--
Eric Wheeler


