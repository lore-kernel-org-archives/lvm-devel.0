From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:05:54 +0000
Subject: [PATCH 21/23] Add default error path for get_property
In-Reply-To: <448fdedd7f429eb2a94c0f31ed4b85a7fb73eea1.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<448fdedd7f429eb2a94c0f31ed4b85a7fb73eea1.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105020554.GQ10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:53PM +0100, Zdenek Kabelac wrote:
> Set invalid property value for error path when none of handlers is set.
> Fixes use of uninitialized prop variable.
 
Ack.

> Maybe add log_error() for this programming error?
 
You could probably add a log_errno() for errors with use of the library
interface, yes.

Alasdair


