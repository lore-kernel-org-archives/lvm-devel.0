From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 21 Sep 2007 12:43:56 +0100
Subject: revised error output: Run ... --help for more information
In-Reply-To: <877imkfe84.fsf_-_@rho.meyering.net>
References: <878x75cuy9.fsf@rho.meyering.net>
	<20070917190950.GM18444@agk.fab.redhat.com>
	<877imkfe84.fsf_-_@rho.meyering.net>
Message-ID: <20070921114356.GW18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Be aware that this is partly configurable already, but
can still come out looking a bit of a mess.
E.g. In lvm.conf set log { command_names = 1 prefix = ": " }

Alasdair
-- 
agk at redhat.com


