From: Milan Broz <mbroz@redhat.com>
Date: Thu, 24 Mar 2011 13:31:38 +0100
Subject: [PATCH 2/4] Fix access to released memory
In-Reply-To: <4243866e4a2da7915b2beecef105358c658664e4.1300965223.git.zkabelac@redhat.com>
References: <cover.1300965223.git.zkabelac@redhat.com>
	<4243866e4a2da7915b2beecef105358c658664e4.1300965223.git.zkabelac@redhat.com>
Message-ID: <4D8B39AA.7090308@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On 03/24/2011 12:16 PM, Zdenek Kabelac wrote:

> Invalid primary_vginfo  was supposed to move all its lvmcache_info to
> orphan_vginfo - however it has called _drop_vginfo() inside the loop
> that remove primary_vginfo itself - thus made the loop using released
> memory.

ack (we talked about it yesterday)

Milan


