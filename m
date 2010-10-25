From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:02:29 +0100
Subject: [PATCH 07/30] Ensure seg is nonnull
In-Reply-To: <afaeb1ba5334b0f63fd3b92bc78c2f7fa577cff5.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<afaeb1ba5334b0f63fd3b92bc78c2f7fa577cff5.1287994529.git.zkabelac@redhat.com>
Message-ID: <87r5fe6156.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:14 +0200,
Zdenek Kabelac wrote:
> 
> clang Logic error	Dereference of null pointer
> Make sure we do not try to use NULL seg pointer.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Does |seg| being NULL indicate a more serious problem?  Should we fail rather than making the best of it and carrying on silently?


