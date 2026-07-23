Over-arching general human and agent expected workflow when using ASC implementations (each step able to be run independently, e.g. across different cronjobs or daemons):

1. Idea -> changelog.draft
1. changelog.draft -> repeat(review -> iterate) until (break | exit) -> state : accepted, rejected / abandonned
1. state : accepted -> repeat(iterate -> test) until (break | exit) -> state : failed, success
1. state (failed | success) : update changelog + next steps - human approval - go / no go -> iterate or implement

-> repeat(review -> iterate) until break / exit (accepted, rejected / abandonned) -> update changelog + next steps - human approval - go / no go -> iterate or implement

--

chaining  
next steps  
intent  
chain-of-thought  
rules modules but for cwt  
migrate module but for cwt (transcriptions, insta, etc)  
task-oriented  
knowledge-oriented

Memory + storage

Blueprint + preflight (before after, git diff manual fixes as source of truth, lessons learned ?)  
Agents custom acl + dsl ?  
Link and pattern building from projet complexe  
Recursion ?  
Tree leaf etc visualização

--

Stories to describe ideas ?

--

Yodo gitflow  
Git commits temples  
Prompt template 

seed.able = freeze.able = export.able ?

Idea - change - review - next steps !!!

+ post-processed (synonyms : static export, static $subject generated / generator, compile.able ?)

--

gitflow.able !  
git commits templates, presets, auto push allowed, gates !  
[https://github.com/dengmengmian/agentgate-ai](https://github.com/dengmengmian/agentgate-ai) ?  
[https://github.com/agentkitai/agentgate](https://github.com/agentkitai/agentgate) ?
