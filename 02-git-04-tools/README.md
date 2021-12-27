*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 2.4 Инструменты Git

## Задание #1

1. Полный хеш и комментарий коммита `aefea` выводится с помощью команды: `git show aefea`
```
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

Update CHANGELOG.md
```
2. Командой `git show 85024d3` просмотрел комментарий коммита и полный хеш с указанием тега `v0.12.23` коммита.
```
commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
Author: tf-release-bot <terraform@hashicorp.com>
Date:   Thu Mar 5 20:56:10 2020 +0000

    v0.12.23
```
3. Командой `git rev-parse b8d720^@` посмотрел сколько родителей у коммита `b8d720`

```
56cd7859e05c36c06b56d013b55a252d0bb7e158
9ea88f22fc6269854151c571162c5bcf958bee2b
```
У коммита `b8d720` два родителя `56cd7859e` и `9ea88f22f`
```
commit 56cd7859e05c36c06b56d013b55a252d0bb7e158
Merge: 58dcac4b7 ffbcf5581
Author: Chris Griggs <cgriggs@hashicorp.com>
Date:   Mon Jan 13 13:19:09 2020 -0800

    Merge pull request #23857 from hashicorp/cgriggs01-stable

    [cherry-pick]add checkpoint links
```
```
commit 9ea88f22fc6269854151c571162c5bcf958bee2b
Author: Chris Griggs <cgriggs@hashicorp.com>
Date:   Tue Jan 21 17:08:06 2020 -0800

    add/update community provider listings
```

4. Командой `git rev-list --pretty=oneline v0.12.23..v0.12.24` перечислил хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.
```
33ff1c03bb960b332be3af2e333462dde88b279e v0.12.24
b14b74c4939dcab573326f4e3ee2a62e23e12f89 [Website] vmc provider links
3f235065b9347a758efadc92295b540ee0a5e26e Update CHANGELOG.md
6ae64e247b332925b872447e9ce869657281c2bf registry: Fix panic when server is unreachable
5c619ca1baf2e21a155fcdb4c264cc9e24a2a353 website: Remove links to the getting started guide's old location
06275647e2b53d97d4f0a19a0fec11f6d69820b5 Update CHANGELOG.md
d5f9411f5108260320064349b757f55c09bc4b80 command: Fix bug when using terraform login on Windows
4b6d06cc5dcb78af637bbb19c198faff37a066ed Update CHANGELOG.md
dd01a35078f040ca984cdd349f18d0b67e486c35 Update CHANGELOG.md
225466bc3e5f35baa5d07197bbc079345b77525e Cleanup after v0.12.23 release
```
5. Командой `git log -S 'func providerSource(' --oneline` нашел коммит в котором была создана функция `func providerSource`
```
8c928e835 main: Consult local directories as potential mirrors of providers
```
Командой `git show 8c928e835` посмотрел полный вывод коммита со всеми изменениями.

6. Командой `git log -L :'func globalPluginDirs':plugins.go --oneline` нашел все коммиты в которых была изменена функция `globalPluginDirs`
```
...
8364383c3 Push plugin discovery down into command package
```
```diff --git a/plugins.go b/plugins.go
--- /dev/null
+++ b/plugins.go
@@ -0,0 +16,22 @@
+func globalPluginDirs() []string {
+       var ret []string
+
+       // Look in the same directory as the Terraform executable.
+       // If found, this replaces what we found in the config path.
+       exePath, err := osext.Executable()
+       if err != nil {
+               log.Printf("[ERROR] Error discovering exe directory: %s", err)
+       } else {
+               ret = append(ret, filepath.Dir(exePath))
+       }
+
+       // Look in ~/.terraform.d/plugins/ , or its equivalent on non-UNIX
+       dir, err := ConfigDir()
+       if err != nil {
+               log.Printf("[ERROR] Error finding global config directory: %s", err)
+       } else {
+               ret = append(ret, filepath.Join(dir, "plugins"))
+       }
+
+       return ret
+}
```
7. Командой `git log -S 'func synchronizedWriters' --pretty=format:'%h - %an %ae'` нашел коммит создания функции `synchronizedWriters` и ее автора `Martin Atkins <mart@degeneration.co.uk>`.
```
5ac311e2a - Martin Atkins mart@degeneration.co.uk
```
