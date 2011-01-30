From: Milan Broz <mbroz@redhat.com>
Date: Sun, 30 Jan 2011 21:44:58 +0100
Subject: [PATCH 20/24] Const fixing
In-Reply-To: <692b32c0cb06e6f3f0b0b7619e04c128bcaaa3fb.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
	<692b32c0cb06e6f3f0b0b7619e04c128bcaaa3fb.1296391340.git.zkabelac@redhat.com>
Message-ID: <4D45CDCA.9080203@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2011 01:57 PM, Zdenek Kabelac wrote:
> Fixing some of the remaining const warnings - major change:
> 
> int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
> 
> Change is needed - as lvm2api seems to expect const behaviour here.
> So vg_extend() is doing local strdup for unescaping.
> 
> skip_dev_dir return const char* from const char* vg_name.

Only C language allows us to have properly defined const variables :-)

<add mornfall's signature here>

If it helps something, ACK.

Milan


