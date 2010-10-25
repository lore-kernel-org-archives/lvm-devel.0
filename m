From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 11:18:03 +0100
Subject: [PATCH 13/30] Eliminate uninitialized_var
In-Reply-To: <0f16dc9e1e7859ac7a275bbd9218dda77bcabc7f.1287994530.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<0f16dc9e1e7859ac7a275bbd9218dda77bcabc7f.1287994530.git.zkabelac@redhat.com>
Message-ID: <87k4l660f8.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 10:24:20 +0200,
Zdenek Kabelac wrote:
> 
> Use some default value instead of a random number for unknown
> minor_version.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>

Nack.  What if your default |sb_offset| is wrong?


