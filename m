From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:04:11 +0100
Subject: [PATCH 06/30] Ensure we always have origin defined
In-Reply-To: <95e3333c3c671cabbc5a99a2bfbbc15dcf948f32.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<95e3333c3c671cabbc5a99a2bfbbc15dcf948f32.1287994529.git.zkabelac@redhat.com>
Message-ID: <87ocai612c.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:13 +0200,
Zdenek Kabelac wrote:
> 
> clang Logic error	Dereference of null pointer
> Ensure the code path could not use origin == NULL because of internal
> error in code.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Ack


