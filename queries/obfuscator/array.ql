/**
 * @name array
 * @description Obfuscation
 * @kind path-problem
 * @problem.severity error
 * @security-severity 1.0
 * @precision low
 * @id npm/test-pls
 * @tags security
 *       obfuscator
 *       patterns
 */

import javascript
import DataFlow::PathGraph


// The malicious package was obfuscated using "JavaScript Obfuscator Tool" (https://obfuscator.io).
// A particular aspect of this tool is that it stores function names as strings in an array, which
// are retrieved during execution making it hard to statically analyze.

// The following query is just an attempt to capture this highly suspicious behaviour.

// Hints of Obfuscation
// --------------------
// >) Sorting
// >>>) array literal > take an element > apply parseInt                 | (NO)
// >>>) array literal > apply push-&-shift                               | (NO)
// >) Flow
// >>>) array literal > take an element > use for method-call naming     | (OK)
// >) Other
// >>>) array literal > check an element > has "num-char" string format  | (OK)


class TargetArray extends DataFlow::ArrayLiteralNode {
    // CharPred
    TargetArray() {
        // At least one element is a string with "digits-letters" format
        exists( DataFlow::ValueNode n, string s
              | n = this.getAnElement()
              | n.mayHaveStringValue(s) and s.regexpMatch("[0-9]+[a-zA-Z]+")
              )
    }
}


// Taint-Tracking configuration for this problem
class Obfuscator_Configuration extends TaintTracking::Configuration {
    Obfuscator_Configuration() { this = "Obfuscator" }

    // Source: Array with suspicious strings
    override predicate isSource(DataFlow::Node source) { source instanceof TargetArray }

    // Sink: Obfuscated method-call
    override predicate isSink(DataFlow::Node sink) {
        // Access for a computed-property (from array value) to a method-call
        exists( DataFlow::MethodCallNode call, DataFlow::PropRead access, Expr property
              | call.getCalleeNode() = access and access.getPropertyNameExpr() = property
              | property.flow() = sink
              )
    }
}


from Obfuscator_Configuration cfg,
     DataFlow::PathNode source, DataFlow::PathNode sink
where cfg.hasFlowPath(source, sink)
  // Be sure that source and sink are in the same file
  and source.getNode().getFile() = sink.getNode().getFile()
select sink.getNode(),
       source,
       sink,
       "$@ to $@",
       source.getNode(),
       "SOURCE",
       sink.getNode(),
       "SINK"
