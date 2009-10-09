From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 9 Oct 2009 17:00:08 +0200
Subject: [PATCH 10/11] debian: make the subdir recursion -j capable
In-Reply-To: <20091008235709.GX3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<14be282c1124b6bcb3652593127d3878707585fc.1255002311.git.fdinitto@redhat.com>
	<20091008235709.GX3054@agk-dp.fab.redhat.com>
Message-ID: <20091009150008.GB6904@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 12:57:09AM +0100, Alasdair G Kergon wrote:
> The tree isn't constructed for a basic recursion mechanism to work
> properly at the moment, and the inter-dependencies all play a role in
> coping with whatever configuration and make targets are thrown at it.
> (Nor does the current setup work perfectly today.)

Even the dependencies reduces it to a simple recursion model. make is
simply not able to provide something else if you don't use one large
makefile. And it works quite well.

Bastian

-- 
Killing is wrong.
		-- Losira, "That Which Survives", stardate unknown


