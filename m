Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793279563;
	b=0ETno0zThk0I6eGSmSY+ru+1bI4Wqwjs1b2jGl0mUbyMFbR+30AYaecJ5KA8jdp7Qksr
	 5GsdYNa+RcFHq7jFHaKiuTD/vb7gpxG2CzZGzdsdKdhAwj3Z6Tk0sYFivMRUsXkDya+08
	 FSy4FSrR2Cm1hlkfz0SwRf/udJhfZy2Nf3b5WHMMZhofHHsOmJ6Xv1KnltExHaAspISnT
	 p1fJ949q5oMpfi5OpY+7Kzy6cZJrT3sSQp0UpfFr4+U5bHdEfRvp2K0vEkBrsYqFAEKrA
	 vdthIH83H7Zl9en54K0015pLT7Mt1tgRVUylgIQe/71hAz5ThD4TSKxIgQkDAqp5cLg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793279563;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:
	 X-Received:Received:Message-ID:Date:MIME-Version:User-Agent:Subject:
	 To:References:From:Organization:In-Reply-To:X-Mimecast-Spam-Score:
	 X-Mimecast-MFC-PROC-ID:X-Mimecast-Originator:Content-Language:
	 Content-Type:Content-Transfer-Encoding;
	bh=Ljb5IArtpozqMQzldZrlGY8URpHPbrtTj+stFivb2hA=;
	b=U8GZ89oLZVGJeybhgKX5iZAi/IxnM+eEGd10kcfcFA1HWXVF6BfJksyUQRGgI/xw7zf4
	 2/CWRkhRjdPDOnqUhq0d/vDnRj2G25ESqjXptYkigahxMimjdnSGoAa4sbRqhKZ0/Mn88
	 uBJK1wwmPAlv6aXOcw8WBBhmkgKuu8o4bSSq1iSd0+BnZWmMorYPVuWyEGG+OiieTYcch
	 eQYvtCI8jsV0CnjhUuiKyXlPtPvwcwRVJeQJ/o98wH3gR/6C7JUzdf39ahIEjwIsTSLi9
	 Wf1jw7KuuhmvXzjMi3Txl/YBwC57TAxeoYECHtLpyluSIp6UPmU3DDOtE2qf0JkcR6A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=U26VfnBd;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D1AF606A323
	for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 13:12:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8D1AF606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=U26VfnBd
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793279561;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Ljb5IArtpozqMQzldZrlGY8URpHPbrtTj+stFivb2hA=;
	b=U26VfnBd4pXAAWiiocKTYiSCjKZovnGYLsGPTOL9vPd3qscZ/2dGf1PZDwfJGvbcutwHvM
	3LEGoQAlf/rBhRkZwP1RJtOj74FoVS2fkeiQxfD09mIZQ+l8P0EpRSmBduSw/epb/wSeW0
	guDpFe02GnAxi/ugSvekTL1IGktYD9c=
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com
 [209.85.128.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-58-Dj1LV8B6Mwmdwqgsf3FklQ-1; Thu, 29 Oct 2026 09:12:39 -0400
X-MC-Unique: Dj1LV8B6Mwmdwqgsf3FklQ-1
X-Mimecast-MFC-AGG-ID: Dj1LV8B6Mwmdwqgsf3FklQ_1793279559
Received: by mail-wm1-f71.google.com with SMTP id 5b1f17b1804b1-4a210f93860so15333605e9.0
        for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 06:12:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793279558; x=1793884358;
        h=content-transfer-encoding:content-type:in-reply-to:organization
         :from:content-language:references:to:subject:user-agent:mime-version
         :date:message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Ljb5IArtpozqMQzldZrlGY8URpHPbrtTj+stFivb2hA=;
        b=Z9F3kYMGnu54LfrQg52v0zvD8mXwBpYUn1pX1j8g+bM3vg+aIncykUT6UwwCcSvhoX
         nMSqVoWct5ymUkDmN5bHiGwkdcV5xQybLqcpk204LAo457kbFUz9RmaDxQklC8giJZTq
         kqGm0Ob8K8w+dV4MbPQEggO0XIP0FTwj7gLdWSwQyh0JBRxZEPaOvf6AG+8+WbMaoHGL
         mmUgHzAnQ5tJkumQ2Qgz8mdGtm5kmjxXeknhtpzVqoAdSGjqYCtABq8543czCCyketQ1
         7mU+ZWOKnNmageRBmftDiKiX/SE0CGsyVnI+xEfEOv1xEKxTzYZ9Num6yc+/lOH+22d5
         IE6w==
X-Forwarded-Encrypted: i=1; AKwUvBzcoHfVKQfvlk5e9f8xyfisz6vkO+zVJQcvxD0xvkEMYy0Za2K/2RKMiW5s8FNrsmrpWQAJFTPZul8=@lists.linux.dev
X-Gm-Message-State: AFq9FYIvzLFqBzJYPSocMbI30axZgstmSFBFe0ujBwWJ2VROTq9qROgO
	bjRZYiUpDqRN3zi+E4Hghd4lRUaFAkSP8sn5mnlvDmDySHh0rJ5y5fTyOG4Dtuhw0FL2BGVCrHY
	CLj89zMIL4hz2yqI8nGGfbpYolW4dATgOdrmAGKq1KWjvD5p0SE2ndRBMv2HUKbrHzRfejw==
X-Gm-Gg: AYBFou1BBw53FfgOtq6UgziC3pDFOhYuY7D+77BBj7zJqYd4/n1XhuDpFiKl6vGft8q
	1AF09tyANaHx2e7M3pHW/mGbyDUnKnmjdkDjBjsytid19N8ASIHUwuo4MSDAeRMEd/7pflHejId
	FfFrscxJMOphJo+AecOTAYs/9mlnDWjm8RvYwii7f1DhKXSEgeKPBUoE0dO1/e3+HLhg2m4PWJ6
	B8xHaZpZ5UT/ZsAFeUHu2ft8TsAkyUBIb++VbklSlKhRnoVRluZ0iVjHa3DFipbP/sSTJ4o8LxE
	4TbbRBSNAERyelhZeufoasi/Z8/NN6v1DmDKKt9lQTvmUF9i0FzRcQXs+FoSnQ6P9uY1IntqmbP
	MzokkcdxfVi2t6UeqSf4zOc7BXG64fTiJNH9wKA==
X-Received: by 2002:a05:600c:3e0a:b0:4a0:1c0e:b057 with SMTP id 5b1f17b1804b1-4a9640f1fbdmr127113685e9.4.1793279558550;
        Thu, 29 Oct 2026 06:12:38 -0700 (PDT)
X-Received: by 2002:a05:600c:3e0a:b0:4a0:1c0e:b057 with SMTP id 5b1f17b1804b1-4a9640f1fbdmr127113015e9.4.1793279558090;
        Thu, 29 Oct 2026 06:12:38 -0700 (PDT)
Received: from [10.43.17.4] ([213.175.46.86])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4aa7c1302f6sm72744735e9.0.2026.10.29.06.12.36
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 29 Oct 2026 06:12:36 -0700 (PDT)
Message-ID: <e297d16a-58e9-40b2-9f1d-8baaf29e823e@redhat.com>
Date: Thu, 29 Oct 2026 14:12:34 +0100
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] label: fix writes when the logical block size is not 512
 or 4096
To: Itai Handler <itai.handler@gmail.com>, lvm-devel@lists.linux.dev
References: <20261029125312.3631129-1-itai.handler@gmail.com>
From: Zdenek Kabelac <zkabelac@redhat.com>
Organization: RedHat
In-Reply-To: <20261029125312.3631129-1-itai.handler@gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: _t19UDKOK3gNirY2wt61rLkDa3_vfzsFGtkbZzq_T04_1793279559
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs-CZ
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 29. 10. 26 v 13:53 Itai Handler napsal(a):
> Since lvm2 2.03.06, LVM cannot be used on a device whose logical block
> size, the smallest unit it can read or write, is neither 512 nor 4096
> bytes.  pvcreate, which prepares a device for LVM, fails:
> 
>    # truncate -s 64M disk.img
>    # losetup --sector-size 2048 --show -f disk.img
>    /dev/loop8
>    # pvcreate /dev/loop8
>      WARNING: threads io engine write device offset 0 len 4608: Invalid argument.
>      Error writing device /dev/loop8 at 4096 length 512.
>      Failed to write mda header to /dev/loop8.
>      Failed to write physical volume "/dev/loop8".

Hi

Hmm - this thread io engine is surely a new logic we are putting in.

I'd like to know more details what is the scenario we are trying to solve - 
normally we expect devices to really have 512 or 4K writable blocks.

We have some set of patches to improve support on systems with 64K pagesize.

But I'm puzzled from where do we get  1K or 2K block sizes ??

> Fix this by rounding up to the logical block size of the device when
> it is neither 512 nor 4096.  Writes then cover a little more of the
> device, but the extra bytes are rewritten with the data already there,
> just as on devices with 4096-byte blocks.  Devices with 512- or
> 4096-byte blocks, which are almost all disks, are not affected.

I think we want to fully hide this in blkio -  label layer should be above.

So I will think more about this.

> 
> Devices with other block sizes are uncommon, but easy to create: loop

Can you tell why do you actually need to use this blocksize - IMHO it must 
bring some inefficiency ??


Regards

Zdenek

