From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 00:28:19 +0000
Subject: [PATCH 07/23] Move lastfd handling into for()
In-Reply-To: <4D11D008.1010303@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<403be35b0f1d1d1da149e3d9a948a6416475287e.1292945707.git.zkabelac@redhat.com>
	<4D10DAC1.9050708@redhat.com> <4D11D008.1010303@redhat.com>
Message-ID: <20110105002819.GF10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 22, 2010 at 11:16:40AM +0100, Zdenek Kabelac wrote:
> Other question is - if we do not support gulm anymore - why do we keep
> unmaintained and untested code ? :)
 
If this is gulm-only code, just leave it exactly as it is.  No need to
try to clean it up or to fix theoretical problems in it unless
responding to patches from people using it and trying to fix it.

Alasdair


