From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 25 Nov 2013 12:33:34 -0500 (EST)
Subject: A bug in snapshot space calculation
Message-ID: <alpine.LRH.2.02.1311251159540.5534@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I looked at bug 916746 and patch 
https://www.redhat.com/archives/lvm-devel/2013-May/msg00135.html - it 
limits the snapshot size 

There are problems:


1) when a metadata chunk is filled completely, you need one more chunk for 
next metadata area

For example, suppose that you have 4k chunk size and 256 data chunks (so 
that all data chunks fill one metadata area). Metadata then looks like 
this:

SUPERBLOCK
METADATA (containing records DATA 0 ... 255)
DATA 0
DATA 1
DATA 2
...
DATA 255
METADATA (containing all zeros)

This extra metadata area if metadata fills up the previous area is not 
accounted for in the code.

The code should be changed to look like this:
uint64_t origin_chunks = (origin_size + chunk_size - 1) / chunk_size;
uint64_t chunks_per_metadata_area = (uint64_t)chunk_size << (SECTOR_SHIFT - 4);
/* note that there is no "- 1" in the next line, so we allocate one more 
   metadata area if the last area is filled up completely */
uint64_t metadata_chunks = (origin_chunks + chunks_per_metadata_area) / chunks_per_metadata_area;
return (1 + origin_chunks + metadata_chunks) * chunk_size;



2) in case of crash, snapshots may leak space. Consequently, we should to 
reserve a few more chunks to account for this possible leaking.

The reason for space leaking is that chunks in the snapshot device are 
allocated sequentially, but they are finished (and stored in the metadata) 
out of order, depending on the order in which copying finished.

For example, supposed that the metadata contains the following records
SUEPRBLOCK
METADATA (blocks 0 ... 250)
DATA 0
DATA 1
DATA 2
...
DATA 250

Now suppose that you allocate 10 new data blocks 251-260. Suppose, that 
copying of these blocks finish out of order (with the block 260 finished 
first and the block 251 finished last). Now, the snapshot device looks 
like this:
SUPERBLOCK
METADATA (blocks 0 ... 250, 260, 259, 258, 257, 256)
DATA 0
DATA 1
DATA 2
...
DATA 250
DATA 251
DATA 252
DATA 253
DATA 254
DATA 255
METADATA (blocks 255, 254, 253, 252, 251)
DATA 256
DATA 257
DATA 258
DATA 259
DATA 260

Now, if the machine crashes after writing the first metadata block and 
before writing the second metadata block, the space for areas DATA 250-255 
is leaked, it contains no valid data and it will never be used in the 
future.

Maybe this could be fixed in the kernel by storing completed exceptions in 
another list and forcing in-order completion.

But until this is fixed, the userspace code should reserve some extra 
space in the snapshot for the possibility of space leaking.

Mikulas


