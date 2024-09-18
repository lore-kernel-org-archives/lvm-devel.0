Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAA891CD23
	for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 12:28:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.49
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1726662505; cv=none; b=BsgkNdMeLTZk1WlfELNJ6hkMeN4R3OEoIdxtrZWwKBHOElST+ilwqk6Ot6gOhAYqOFsDPA8+LsU2cEsbosUdQ0+IMEVBpmU5/OxfWNTlWzouU6KS2lM50rZZ2Z+dacYYXxI2cQSvQ79QOXciMfGbdfWSuebIgck2C0omWMxmjcY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1726662505; c=relaxed/simple;
	bh=X/9cSB6DVhLbXqyl0sGdbt8P6kvA94svCRV8vWt0GGo=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=V5B3HJKYwBs2B5i0t7Brow4qawh6haY406xqeowRhvjA7nOoA16pCgM2Y7xJiu2jNiDIWEdhsBSHwAp2PFx8kXSUUEaGVWI5yxglsor+PfarU85GoolZrlqbb8edJYOqWEOmLtUm1jTcUrS83sGUFOhkDTMO1f/rMumzGrs3fWI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=AXzd6rYa; arc=none smtp.client-ip=209.85.128.49
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AXzd6rYa"
Received: by mail-wm1-f49.google.com with SMTP id 5b1f17b1804b1-42cde6b5094so55267205e9.3
        for <lvm-devel@lists.linux.dev>; Wed, 18 Sep 2024 05:28:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1726662502; x=1727267302; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id:from
         :to:cc:subject:date:message-id:reply-to;
        bh=hjL5dr/9XCZCE9MxMX4FJQ6wY6jt/BnPg8UQ1R5NHH8=;
        b=AXzd6rYa13uaXmnwtYsKah11OA72rkFEXfalkey+K7Y+tbYGcIbhVqPhTuGSrzQqhC
         ZNhk7m+6+2Gz4n098KVemUIqthpZV+Hr02lEpTHBoEyFYiyezX+kU6TuQ/7Tif/chQX9
         j2OozcQTi0dcfdMKTZO+srC14jBBuVrtAXBIs4OCzD9/24BuBA7jpBYmwn30Vi1RiKJw
         L2j5VNMjMuucyOtPidTvrHRxIuIahvR26vfm/eQDhDW3KyHxQRXcNj6MKEV8ROd9H7fn
         myoI6IiH+KbV823Re8zxppPsuvWGbGdH1i/xMcJ8Gf2IIh/wicZD9/70bJd/ye/UoSTq
         M2IA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1726662502; x=1727267302;
        h=content-transfer-encoding:in-reply-to:from:content-language
         :references:to:subject:user-agent:mime-version:date:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=hjL5dr/9XCZCE9MxMX4FJQ6wY6jt/BnPg8UQ1R5NHH8=;
        b=vpTD1z3biYvOptdPqmNgxTI2owNBlFVHRGFtNG7dFVRXIiXoPISZZLlWrwS2p83sm+
         K2fKbfA0VjtwIOVNXggpPS+eYGHsI+JM1ERL+vUuRtOzog5ATnqdLMJHDl/gTxROUUe5
         WE5ZxhJaLFtzdqH6Q0BTMGtgdzB+fqZSym8vRmo+SVZpoHWijBJGwMZUcFNnylxo2zIo
         g5EcnWzZPmtkO+bFrVfQ9twsLeDjxhYxl6sYN70GRRIbiUB3hJ1+jO/yyKQZxtXgE7Pz
         4LLEOWjvWToUsbLoau+glHdRFwS3BR8osmxEOudpHY4etX2jOqNyQNAqoiQejgnSrxgq
         LBsA==
X-Forwarded-Encrypted: i=1; AJvYcCW+OO4T+mD31jWfYo8TF0TEHN844OnUSJT5eGzYOVreD76UR/VUj+Mxqtugf+coj8X3UCYNnriypiA=@lists.linux.dev
X-Gm-Message-State: AOJu0Yxr+YSMWQyVyoU8xTCdRkz3h9RZFtXU63NRmDIbbfCoYItXzlsP
	/7ueqy5iUXSaNkmeRFzjtnEkybUpzgfSsez/pbu3fjXV3yK3n5xT
X-Google-Smtp-Source: AGHT+IFImdNOa3P7jams3fVGe8gnxqx6f4i9LAYNFR86nmEOX5NMYJA5HI/J7A8DOWOPrjD1I7emYg==
X-Received: by 2002:a05:600c:5127:b0:426:67ad:38e3 with SMTP id 5b1f17b1804b1-42cdb531b27mr171814025e9.3.1726662501630;
        Wed, 18 Sep 2024 05:28:21 -0700 (PDT)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-378e72e49bfsm12197867f8f.21.2024.09.18.05.28.20
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 18 Sep 2024 05:28:21 -0700 (PDT)
Message-ID: <a32fcb13-e0fc-439f-9f93-c7b499744d7d@gmail.com>
Date: Wed, 18 Sep 2024 14:28:19 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Reg thin pool activation failure - transaction id mismatch
To: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>,
 lvm-devel@lists.linux.dev
References: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
Content-Language: en-US, cs
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
In-Reply-To: <CAFe+wq1hQ=jV9bELpm4RXw1=6vPN7hriX0gV6OetNukBEu3ayA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Dne 18. 09. 24 v 12:54 Lakshmi Narasimhan Sundararajan napsal(a):
> Hi Team,
> Good day all!
>
> In yet another long testing run, I see a thin pool was unable to get
> volume group thin pool activated.
> vgchange -ay <vgname> fails with
>
> ```
> /# vgchange -ay pwx3
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
> Thin pool pwx3-pxpool-tpool (253:25) transaction_id is 6, while expected 24.
> 3 logical volume(s) in volume group "pwx3" now active
> ```
> It had other non thin lvols in the vg that got activated successfully.
>
> I tried fixing the pool, by trying the following ``` lvconvert
> --repair pwx3 ``` but this fails to fix the thin pool.
>
> There was last configuration in the lvm config backup location.
> I fixed the transaction id and used `vgcfgrestore --force -f <patched
> config> pwx3` and this fixed the transaction id issue and vg was now
> successfully activated.


Hi


Well this sounds like you were doing something 'very unhealthy' to your 
thin-pool - possibly 'restoring' old thin-pool metadata ??

TransactionId - is basically increased with lvm2 every transaction - i.e. 
adding/removing a 'thin LV' to the thin-pool.

Difference by such a large amount means something went seriously wrong in your 
system - is thin-pool suddenly started to expose very old 'transaction_id' - 
like it it would have lost everything else  from that time - so likely also 
all the mappings of thin volumes....

So basically until we know what you were doing with your system - it's very 
hard to tell want went wrong in your particular case.

What we can say for sure is - that if you have use 'vgcfgrestore'  to fix your 
'mismatching' transaction id - you just left your thin-pool problem 'hidden'  
and it will 'bite' in the moment you will try to access your now 'lost' data.

>
> And my follow up questions are:
> 1/ what exactly is a transaction id mismatch problem?
> A little more detail about this problem will help me understand this better.
>
> 2/ Are there any known workflows that are known to create this issue?
> So I can be careful to avoid such workflows.

There can be possible a mismatch by 1 -  although we try hard to catch all 
such cases - so it should be very hard to get into such state.

Your difference  by   >1  number sounds like you were doing something very 
'unusual' to your storage that thin-pool -  you will need to expose way more 
details here...


> 3/ does recovery as above guarantee data in the pool? or is the pool
> data suspect?


Absolutely NOT.

Thin-pool metadata must be recovered properly to match  lvm2 view -  and if 
that's not possible - there is relatively lot of work to get things in correct 
shape - it can be so complex it can be simply easier to just recover from 
backup in such case.


Regards

Zdenek


