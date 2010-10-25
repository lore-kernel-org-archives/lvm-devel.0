From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:07:37 +0100
Subject: [PATCH 08/30] Ensure first is not NULL
In-Reply-To: <a1f0ffae5f0040b65da905155599c68712b800f5.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<a1f0ffae5f0040b65da905155599c68712b800f5.1287994530.git.zkabelac@redhat.com>
Message-ID: <87mxq260wm.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:15 +0200,
Zdenek Kabelac wrote:
> 
> clang Logic error	Dereference of null pointer
> 
> For empty lists make sure the NULL first pointer is not dereferenced.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Again I'm worried you're hiding a problem.  Can |first| be NULL, what does it mean?


