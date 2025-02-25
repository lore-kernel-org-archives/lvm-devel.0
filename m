Received: from mail-ed1-f46.google.com (mail-ed1-f46.google.com [209.85.208.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE9C225D533
	for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 09:06:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1740474390; cv=none; b=S2DbAgP8yvjtAMKJgTBDXdQPoCXvECvYfBpRRAwC1Z+E5h6dpZXqlNUQih0ROPZtt32tiUx4HdpW9xKEgu/YSUIUusJFC+3AIGoBstzOJSVP/CXDKGCiQiwyZiRx7sA8vWwA1rmagMnQ/n0LLQMwi3Mqb1Bzh/fM8WM7IY6cI44=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1740474390; c=relaxed/simple;
	bh=RhPx1blIjrjwSd1k5E4kKu5/ltCQPqe2cLAN5v5kvpo=;
	h=From:Message-ID:Date:MIME-Version:Subject:To:Cc:References:
	 In-Reply-To:Content-Type; b=D9jm7X/rYiTAZoAKLHphU3Y2WqqzLQjbXW7hnIf2uj+BxPEfe9Ivmj4eFy16IAWW9uW5zd0XgLE3g4TbLzTjWrQ99PHwW5HI/Lb1hOJQgCu61LJ6Qr5oarP4fVbxXHAdm4Ex86joR3NPC0qvB+68ngZwB+2bwSRquN4/djWGrV4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=gvocBoK7; arc=none smtp.client-ip=209.85.208.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gvocBoK7"
Received: by mail-ed1-f46.google.com with SMTP id 4fb4d7f45d1cf-5ded1395213so8972762a12.2
        for <lvm-devel@lists.linux.dev>; Tue, 25 Feb 2025 01:06:28 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1740474387; x=1741079187; darn=lists.linux.dev;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :cc:to:subject:user-agent:mime-version:date:message-id:from:from:to
         :cc:subject:date:message-id:reply-to;
        bh=1dqlzeVt3+qkM7I0K0g/ddM3os6Q8JsRC2CfUFy1JFs=;
        b=gvocBoK7Jbn0PCHspnbGX0shDhNC+MwSvVthYoNUD10ogLFlJJMdGfj4FXUjbQ+SJs
         035+3fIYQgaUG/nJRBY//sHPZUY0zkWlRPfnmY39iWQvnEtg5h9xxT0akdSQHNiyMRTi
         lef6QXRQr1OJpYQcbd3N26UMkk7HGZfcRwXw4olkomgelOKECHnUopqCTLL4HF3rb7OR
         6IYaFtkAEj/QYSeEUWvJHxvapbOMa49Z9ouiTptnkjMWTtCwuXnQNjJNFi6hQCWb2n1h
         4kZMuVzErjMJlZEvmpb7vm046GlrxoUqA7FJQVeQnOMJ+ajOSrMQcpXP08SSrU4JWH9c
         mtpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1740474387; x=1741079187;
        h=content-transfer-encoding:in-reply-to:content-language:references
         :cc:to:subject:user-agent:mime-version:date:message-id:from
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=1dqlzeVt3+qkM7I0K0g/ddM3os6Q8JsRC2CfUFy1JFs=;
        b=EUwRXPxtnNO0+OZ1d+eU8InWuinxGhXncBFqHxAWbhyU6qLhlTWjiE/bNSF8fTuSUn
         sYIon1Dkr/l2QcwrT0EyDATs+StdUDwrAu2B3iBd3iOc+UOb4ekIZFx3mkuQ2v0s3jmF
         ZCr7cQcAuJSBIRSZLo0Ow8bwEJhBnWOFcXMLDGUZtyYXywcs9jSIlHFq6qn+ebPBZ98y
         3ytFSuUMs+/QI1BWwXyE52Rr6lt17S95PF/rNg+mDDh2Or+YvX6KZR2LuWs/yUNvtcKN
         RI49FyQ3che1+gMEsX1Bra+p7UTd+EJWjEYJcDej9jZZ5aBVhrcMvs2kvbOqvf4Tt9rJ
         wapQ==
X-Gm-Message-State: AOJu0Ywwg+aYpGYDr9FOvy8okV7iZhE6bMbWZcBCmM9km7KWOohutwVX
	uqdtQnh520QFisL7A3sjIHK60dRqlf5lKJhGDD06ito7KVARxukl
X-Gm-Gg: ASbGncsS7ti6wt0IK+DN2lYz0B5pdd57yv7j3/zcwi+f2c6BW6GNz1Oc0lEj8CwIeXt
	gpC/AjH0Cn+IQ4wgIJFc89Vn16zDJhtbRMr3PFDVs9rHnB5nxmqEZw6vpMgGShH1a6NjZze1SMO
	ROwA7nxdPAKoRa7qGtaFooWKOGxlH6e2i1bzi38zaQ6HwKIPeJkPKCZPwX0otbkMiEJsw5gFPYo
	rWCvnjhXCk1xyPCxM+20uOjvGIDprEj2rbWzGdsrdWzk/bedYnZF8qq6cd0zzhE00nN+n9pFxlX
	hT1R680l1a+0Mm8SzxUqtn3ukyUxV3/PoxdZQB0AvXFGrXg6hpxXMRfK4ROGdKEeEMxmj1EfSA=
	=
X-Google-Smtp-Source: AGHT+IGkxb+AA99kMuRcmg1HkGftSKEkO/17AELtzBZhx1CFyJ2MnxgBs4Ykzn3i6NUXVd2IcXyNNQ==
X-Received: by 2002:a05:6402:4304:b0:5e0:4276:c39e with SMTP id 4fb4d7f45d1cf-5e44ba3fe8amr2376068a12.30.1740474386541;
        Tue, 25 Feb 2025 01:06:26 -0800 (PST)
Received: from ?IPV6:2a03:a900:1000:7e9:403e:7c8b:351b:f333? ([2a03:a900:1000:7e9:403e:7c8b:351b:f333])
        by smtp.gmail.com with ESMTPSA id 4fb4d7f45d1cf-5e462126f1dsm902695a12.74.2025.02.25.01.06.24
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Tue, 25 Feb 2025 01:06:25 -0800 (PST)
From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
X-Google-Original-From: Zdenek Kabelac <zkabelac@redhat.com>
Message-ID: <6dc7c3a8-6965-4972-af92-f416c276df8e@redhat.com>
Date: Tue, 25 Feb 2025 10:06:24 +0100
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: Fix the issue of missing symbols in libdevmapper
To: "zengjianqi163@163.co" <zengjianqi163@163.com>,
 Zdenek Kabelac <zdenek.kabelac@gmail.com>
Cc: "lvm-devel@lists.linux.dev" <lvm-devel@lists.linux.dev>
References: <2299fe3d.6a77.1951d2e7409.Coremail.zengjianqi163@163.com>
 <c1d5760e-ee5f-40f8-825f-4c7f44a0aacf@gmail.com>
 <1249d3c8.18cb.19521101544.Coremail.zengjianqi163@163.com>
Content-Language: en-US, cs
In-Reply-To: <1249d3c8.18cb.19521101544.Coremail.zengjianqi163@163.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Dne 20. 02. 25 v 2:54 zengjianqi163@163.co napsal(a):
> Hi, Zdenek
>
> This issue is not from other libdevmapper user.
> I discovered this issue while conducting a compatibility analysis between versions lvm2-2.03.09 and lvm2-2.03.21 before and after the upgrade.
>
> By the way, may I ask if the feasibility of this patch meets the requirements? On which branch of LVM2 can I verify this issue afterward?
>

Hi


Patch is now upstream  (main branch):

https://gitlab.com/lvmteam/lvm2/-/commit/36be0778f846b06243e0079720ba6badec46f24c

I've added comment about the cause of the issue as well and once again thanks 
for noticing this issue.


Regards


Zdenek

