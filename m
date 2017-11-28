From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 28 Nov 2017 11:59:15 +0100
Subject: master - tests: Die on bad argument
In-Reply-To: <201711280822.vAS8MAHY013510@lists01.pubmisc.prod.ext.phx2.redhat.com>
References: <201711280822.vAS8MAHY013510@lists01.pubmisc.prod.ext.phx2.redhat.com>
Message-ID: <bf3b3cf9-828b-f071-fc8e-f48aca08be1a@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 11/28/2017 09:22 AM, Marian Csontos wrote:
> Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7665304604bad894afed5e372263e48b309927d7
> Commit:        7665304604bad894afed5e372263e48b309927d7
> Parent:        591ac0828af73ac9a134660a643ef234ff57c02e
> Author:        Marian Csontos <mcsontos@redhat.com>
> AuthorDate:    Tue Nov 28 09:05:02 2017 +0100
> Committer:     Marian Csontos <mcsontos@redhat.com>
> CommitterDate: Tue Nov 28 09:21:05 2017 +0100
> 
> tests: Die on bad argument
> 
> ---
>   test/lib/aux.sh |    1 +
>   1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/test/lib/aux.sh b/test/lib/aux.sh
> index b8a0cc0..97111c7 100644
> --- a/test/lib/aux.sh
> +++ b/test/lib/aux.sh
> @@ -911,6 +911,7 @@ common_dev_() {
>   
>   	for fromlen in "${@-0:}"; do
>   		from=${fromlen%%:*}
> +		test "$from" = "$fromlen" || die "Bad argument: Missing ':' in FROM:[LEN] argument"

Doh! Written the condition reverted.

>   		len=${fromlen##*:}
>   		test -n "$len" || len=$(( size - from ))
>   		diff=$(( from - pos ))
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
> 

Kabi suggested the intention was to run till the end of device, if `:` 
was missing. The actual implementation assigned `len=$from` without `:` 
- definitely incorrect behavior.

I checked all occurrences and either colon is used, or till the end of 
device was supposed.

I documented the colon, and are force pushing the fix to remove the noise.

-- Martian


