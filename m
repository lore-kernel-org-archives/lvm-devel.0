From: Bastian Blank <bastian@waldi.eu.org>
Date: Mon, 12 Oct 2009 12:54:29 +0200
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <20091012101457.GM19397@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
	<20091009000134.GY3054@agk-dp.fab.redhat.com>
	<20091009150148.GC6904@wavehammer.waldi.eu.org>
	<20091009162914.GH3054@agk-dp.fab.redhat.com>
	<1255339830.10932.52.camel@cerberus.int.fabbione.net>
	<20091012101457.GM19397@agk-dp.fab.redhat.com>
Message-ID: <20091012105429.GC4166@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 12, 2009 at 11:14:57AM +0100, Alasdair G Kergon wrote:
> If I run this outside a packaging framework I still need the permissions
> to be set.

Hu? All it changes is to make them writable for the user. Having
unwritable files does not really make fun.

> So then leave this unchanged, and there is no point in Debian or any other
> packaging system removing the existing permission setting because the packaging
> system is going to override it afterwards anyway.

It still is, because it breaks my assumptions of the development process
to have unwritable files en masse.

Bastian

-- 
Each kiss is as the first.
		-- Miramanee, Kirk's wife, "The Paradise Syndrome",
		   stardate 4842.6


