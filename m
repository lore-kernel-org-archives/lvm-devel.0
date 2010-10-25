From: ejt@redhat.com <ejt@redhat.com>
Date: Mon, 25 Oct 2010 12:21:31 +0100
Subject: [PATCH 13/30] Eliminate uninitialized_var
In-Reply-To: <4CC56649.3070804@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
	<0f16dc9e1e7859ac7a275bbd9218dda77bcabc7f.1287994530.git.zkabelac@redhat.com>
	<87k4l660f8.wl%ejt@redhat.com> <4CC56649.3070804@redhat.com>
Message-ID: <87sjzu4ix0.wl%ejt@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

At Mon, 25 Oct 2010 13:13:13 +0200,
Zdenek Kabelac wrote:
> But this patch is rather about make compiler analyzer quiet -
> maybe  default: assert() for 'generic' version ?

Or just plain abort() so it doesn't get compiled out in the release version?


