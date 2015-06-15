From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 15 Jun 2015 11:12:31 +0200
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
In-Reply-To: <557EAFC6020000E1000108C5@relay2.provo.novell.com>
References: <1434094405-8391-1-git-send-email-lzhong@suse.com>	<557B001F.30804@redhat.com>
	<557EAFC6020000E1000108C5@relay2.provo.novell.com>
Message-ID: <557E96FF.1050509@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.6.2015 v 04:58 Lidong Zhong napsal(a):
>>>> On 6/12/2015 at 11:51 PM, in message <557B001F.30804@redhat.com>, Zdenek
> Kabelac <zkabelac@redhat.com> wrote:
>> Dne 12.6.2015 v 09:33 Lidong Zhong napsal(a):
>>> ---
>>>    make.tmpl.in | 2 +-
>>>    1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/make.tmpl.in b/make.tmpl.in
>>> index 731dab7..60ddd01 100644
>>> --- a/make.tmpl.in
>>> +++ b/make.tmpl.in
>>> @@ -499,7 +499,7 @@ ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
>>>    		 echo "	local:"; echo "		*;"; echo "};") > $@
>>>    else
>>>    	set -e;\
>>> -	R=$$(sort $^ | uniq -u);\
>>> +	R="$$(sort $^ | uniq -u)";\
>>>    	test -z "$$R" || { echo "Mismatch between symbols in shared library and
>> lists in .exported_symbols.* files: $$R"; false; } ;\
>>>    	for i in $(EXPORTED_SYMBOLS); do\
>>>    		echo "$${i##*.} {"; echo "	global:";\
>>
>> Hi
>>
>> Do you have some example where it fails without "" ?
>> Bash normally should assign $VARS directly.
> Hi  Zdenek,
>
> As the `echo` outputs, if there are more symbols got from `sort $^ | uniq -u`, there will be
> an bash error.
> I found this exactly because I forgot to add these symbols to .exported_symbols.* files.

But the bash error here is wanted when symbols are missing - it's the purpose 
to stop compilation. So please specify more closely the example where it fails 
because of missing "".

This output is wanted:

Mismatch between symbols in shared library and lists in .exported_symbols.* 
files: dm_tree_node_set_XXXX
dm_tree_node_set_YYYY
../make.tmpl:501: recipe for target '.export.sym' failed
make: *** [.export.sym] Error 1

If the dm_tree_node_set_XXXX|YYYY is not defined in any .exported_symbols*

Zdenek


