From: Milan Broz <mbroz@redhat.com>
Date: Mon, 21 Dec 2009 19:13:36 +0100
Subject: [PATCH] Invalidate devices in cache after precommited metadata was wiped.
In-Reply-To: <1261323176-13839-1-git-send-email-mbroz@redhat.com>
References: <1261323176-13839-1-git-send-email-mbroz@redhat.com>
Message-ID: <4B2FBAD0.8090300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 12/20/2009 04:32 PM, Milan Broz wrote:
> The only place when vginfo->precommited is set is during
> metadata store in cache.
> 
> It means that if we store precommited metadata in cache,
> then call drop_cached_metadata without subsequent storing
> commited metadata, cache is not invalidated on drop cache call.
> 
> If there is no cached metadata, invalidate device info always.

NACKing this myself, the precommited metadata problem is much more
complex and will require another approach.

Milan


