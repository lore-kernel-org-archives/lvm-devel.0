From: Bastian Blank <bastian@waldi.eu.org>
Date: Sun, 11 Oct 2009 22:23:47 +0200
Subject: [PATCH 01/11] debian: fix library search path in example.conf
In-Reply-To: <1255280941.10932.6.camel@cerberus.int.fabbione.net>
References: <1255002904-6226-1-git-send-email-fdinitto@redhat.com>
	<8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<20091008232725.GP3054@agk-dp.fab.redhat.com>
	<1255280941.10932.6.camel@cerberus.int.fabbione.net>
Message-ID: <20091011202347.GD21726@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 11, 2009 at 07:09:01PM +0200, Fabio M. Di Nitto wrote:
> Other than the example config file there are no traces of /lib/lvm2
> anywhere in the package.

Its currently unused. The cluster locking lib was the only used external
lib.

Bastian

-- 
The sight of death frightens them [Earthers].
		-- Kras the Klingon, "Friday's Child", stardate 3497.2


