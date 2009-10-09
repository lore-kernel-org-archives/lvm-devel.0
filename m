From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 9 Oct 2009 17:02:36 +0200
Subject: [PATCH 03/11] debian: force modprobe
In-Reply-To: <20091008233016.GR3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<eaddb1c0b80c3d362cef5ced6bd556dee82b9e46.1255002311.git.fdinitto@redhat.com>
	<20091008233016.GR3054@agk-dp.fab.redhat.com>
Message-ID: <20091009150236.GD6904@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 12:30:16AM +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:49:10PM +0200, Fabio M. Di Nitto wrote:
> > well, a linux system without modprobe can't use any modules.
> > so this just assumes that it is available in a real system
> I see no need for this one upstream.
> (Things like this are there so the code can be used on some BSD-based systems.)

modprobe is Linux-only, so this useless.

Bastian

-- 
Earth -- mother of the most beautiful women in the universe.
		-- Apollo, "Who Mourns for Adonais?" stardate 3468.1


