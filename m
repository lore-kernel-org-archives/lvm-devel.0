From: David Teigland <teigland@redhat.com>
Date: Wed, 17 Oct 2018 11:50:41 -0500
Subject: LVM2 label and metadata location
In-Reply-To: <923d72c2593cfbd26d8d2da589698851@fau.de>
References: <923d72c2593cfbd26d8d2da589698851@fau.de>
Message-ID: <20181017165041.GB9941@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Oct 13, 2018 at 10:44:22PM +0200, Schneider, Janine wrote:
> I did read the LVM2 documentation and i have tried to find the location
> parsing in the LVM2 code but unfortunately I was unable to figure out how
> this has to be done.

This brief summary might get you started; the structure of the lvm code
doesn't make it easy to find or follow.

The second sector of the disk (offset 512) contains: struct label_header
followed by struct pv_header.  The pv_header (disk_areas) point to the
location of one (or optionally two) struct mda_header.  The first
mda_header is at offset 4096.  (The optional second one is at the end of
the device.)

The sector containing mda_header is followed by many sectors (e.g. 1MB).
These sectors act as a circular buffer containing lvm text metadata.  One
copy of the text metadata is written into this buffer after the last
version.  The mda_header's raw_locn struct points to the latest copy of
the metadata in this buffer.

_find_lvm_header() reads label_header.
_text_read() reads pv_header.
_raw_read_mda_header() reads mda_header
text_read_metadata() reads text metadata


