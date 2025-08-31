---
trigger: always_on
---

1. Patterns are a syntactic category that represent the shape of values for matching and destructuring.
2. Pattern matching checks if a value has a certain shape, constant, equality, or type.
3. Pattern destructuring allows extracting parts of a matched value and binding them to variables.
4. Patterns can be nested, using subpatterns (outer/inner patterns) for recursive matching and destructuring.
5. Use wildcard patterns (`_`) to ignore parts of a matched value; use rest elements in list patterns to ignore remaining elements.
6. Patterns can be used in:
   - Local variable declarations and assignments
   - For and for-in loops
   - If-case and switch-case statements
   - Control flow in collection literals
7. Pattern variable declarations start with `var` or `final` and bind new variables from the matched value. Example: `var (a, [b, c]) = ('str', [1, 2]);`
8. Pattern variable assignments destructure a value and assign to existing variables. Example: `(b, a) = (a, b); // swap values`
9. Every case clause in `switch` and `if-case` contains a pattern. Any kind of pattern can be used in a case.
10. Case patterns are refutable; if the pattern doesn't match, execution continues to the next case.
11. Destructured values in a case become local variables scoped to the case body.
12. Use logical-or patterns (e.g., `case a || b`) to match multiple alternatives in a single case.
13. Use logical-or patterns with guards (`when`) to share a body or guard between cases.
14. Guard clauses (`when`) evaluate a condition after matching; if false, execution proceeds to the next case.
15. Patterns can be used in for and for-in loops to destructure collection elements (e.g., destructuring `MapEntry` in map iteration).
16. Object patterns match named object types and destructure their data using getters. Example: `var Foo(:one, :two) = myFoo;`
17. Constant patterns match if the value is equal to a constant (number, string, bool, named constant, const constructor, const collection, etc.). Use parentheses and `const` for complex expressions.
18. Variable patterns (`var name`, `final Type name`) bind new variables to matched/destructured values. Typed variable patterns only match if the value has the declared type.
19. Identifier patterns (`foo`, `_`) act as variable or constant patterns depending on context. `_` always acts as a wildcard and matches/discards any value.
20. Parenthesized patterns (`(subpattern)`) control pattern precedence and grouping, similar to expressions.
21. List patterns (`[subpattern1, subpattern2]`) match lists and destructure elements by position. The pattern length must match the list unless a rest element is used.
22. Rest elements (`...`, `...rest`) in list patterns match arbitrary-length lists or collect unmatched elements into a new list.
23. Map patterns (`{"key": subpattern}`) match maps and destructure by key. Only specified keys are matched; missing keys throw a `StateError`.
24. Record patterns (`(subpattern1, subpattern2)`, `(x: subpattern1, y: subpattern2)`) match records by shape and destructure positional/named fields. Field names can be omitted if inferred from variable or identifier patterns.
25. Object patterns (`ClassName(field1: subpattern1, field2: subpattern2)`) match objects by type and destructure using getters. Extra fields in the object are ignored.
26. Wildcard patterns (`_`, `Type _`) match any value without binding. Useful for ignoring values or type-checking without binding.
27. All pattern types can be nested and combined for expressive and precise matching and destructuring.
