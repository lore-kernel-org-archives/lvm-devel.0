From: David Teigland <teigland@redhat.com>
Date: Thu, 14 Sep 2017 15:53:27 -0500
Subject: [Patch review 0/1] introduce lvm forcevg option to forcibly deactivate the whole vg
In-Reply-To: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
References: <64076DFF-B489-4F67-A0EB-F0F41DFBD314@huayun.com>
Message-ID: <20170914205327.GA8365@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zhang,

I discussed this with Alasdair who had the good idea that we could do this
with just a couple of dmsetup commands, e.g.

dmsetup info -c -S "uuid=~LVM && vgname=$VG && lv_layer=\"\"" -o name --noheadings | xargs dmsetup wipe_table

If this works, I think it would be a nicer solution than going through the
blkdeactivate script.

Dave


