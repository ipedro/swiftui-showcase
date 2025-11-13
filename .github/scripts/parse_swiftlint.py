import json
import sys

try:
    with open('swiftlint-before.json', 'r') as f:
        violations = json.load(f)
    
    if not violations:
        print("No SwiftLint violations detected")
        sys.exit(0)
    
    # Group by rule
    by_rule = {}
    violation_details = []
    
    for v in violations:
        rule = v.get('rule_id', 'unknown')
        by_rule[rule] = by_rule.get(rule, 0) + 1
        
        file_path = v.get('file', '').replace('/Users/runner/work/swiftui-showcase/swiftui-showcase/', '')
        line = v.get('line', '?')
        severity = v.get('severity', 'warning')
        reason = v.get('reason', 'No description')
        
        violation_details.append({
            'file': file_path,
            'line': line,
            'rule': rule,
            'severity': severity,
            'reason': reason
        })
    
    print(f"### 🔧 SwiftLint Fixes ({len(violations)} violations)\n")
    
    # Show top 10 violations with details
    print("| File:Line | Rule | Severity | Description |")
    print("|-----------|------|----------|-------------|")
    
    for v in violation_details[:10]:
        severity_emoji = "⚠️" if v['severity'] == 'warning' else "🚫"
        rule_link = f"[`{v['rule']}`](https://realm.github.io/SwiftLint/rule-directory.html#{v['rule']})"
        print(f"| `{v['file']}:{v['line']}` | {rule_link} | {severity_emoji} {v['severity']} | {v['reason'][:80]} |")
    
    if len(violation_details) > 10:
        print(f"\n<details>")
        print(f"<summary>📋 View all {len(violation_details)} SwiftLint fixes</summary>\n")
        print("| File:Line | Rule | Severity | Description |")
        print("|-----------|------|----------|-------------|")
        for v in violation_details:
            severity_emoji = "⚠️" if v['severity'] == 'warning' else "🚫"
            rule_link = f"[`{v['rule']}`](https://realm.github.io/SwiftLint/rule-directory.html#{v['rule']})"
            print(f"| `{v['file']}:{v['line']}` | {rule_link} | {severity_emoji} {v['severity']} | {v['reason'][:80]} |")
        print("\n</details>")
    
    # Rules summary
    print("\n### 📊 Rules Summary\n")
    sorted_rules = sorted(by_rule.items(), key=lambda x: x[1], reverse=True)
    for rule, count in sorted_rules:
        rule_link = f"[`{rule}`](https://realm.github.io/SwiftLint/rule-directory.html#{rule})"
        print(f"- {rule_link}: **{count}** fix{'es' if count > 1 else ''}")

except Exception as e:
    print(f"Error parsing SwiftLint output: {e}")
    print("No SwiftLint violations detected")
