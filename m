From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 9 Oct 2009 01:01:34 +0100
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
Message-ID: <20091009000134.GY3054@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Oct 08, 2009 at 02:49:18PM +0200, Fabio M. Di Nitto wrote:
> remove owner and group definitions and install anything writable as mendated
> by the debian policy
 
--with-user= and --with-group= should already handle the owner and group
(i.e. set them to blank like we do in RHEL/Fedora)

The hard-coded perms in the makefiles probably need treating in a similar fashion.

Alasdair


