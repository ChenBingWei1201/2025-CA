# Computer Architecture Midterm Examination - Mock Exam

**Total Points: 100**  
**Time: 120 minutes**  
**Materials Allowed: One A4 sheet with handwritten notes (both sides)**

## Part I: Multiple Choice Questions (20 points - 2 points each)

1. Which of the following is NOT a stage in the classic 5-stage MIPS pipeline?
   a) Instruction Fetch (IF)
   b) Memory Access (MEM)
   c) Execute (EX)
   d) Cache Access (CA)
   e) Write Back (WB)

2. Which of the following correctly represents the sign extension of the 16-bit immediate value 0x8ABC to a 32-bit value?
   a) 0x00008ABC
   b) 0xFFFF8ABC
   c) 0x8ABC0000
   d) 0x8ABCFFFF

3. If the MIPS CPU uses 32 registers, what is the maximum number of registers that can be addressed with the R-type instruction format?
   a) 16
   b) 31
   c) 32
   d) 64

4. When calculating the performance of a processor, which of the following is NOT a contributing factor?
   a) Clock cycle time
   b) CPI (Cycles Per Instruction)
   c) Instruction count
   d) Address space size

5. In the MIPS architecture, which register always contains the value 0?
   a) $s0
   b) $t0
   c) $0
   d) $ra

6. Which of the following instruction formats in MIPS has a 26-bit address field?
   a) R-type
   b) I-type
   c) J-type
   d) None of the above

7. What is the main advantage of pipelining in processor design?
   a) Reduced power consumption
   b) Increased throughput
   c) Elimination of hazards
   d) Simplified instruction set

8. In MIPS, which type of hazard occurs when an instruction depends on data from a previous instruction that has not yet been written back?
   a) Structural hazard
   b) Control hazard
   c) Data hazard
   d) Memory hazard

9. Which of the following leads to the power wall problem in processor design?
   a) Decreasing transistor size
   b) Increasing clock frequency
   c) Increasing pipeline depth
   d) Adding more cores

10. What addressing mode is used in the MIPS instruction "lw $t0, 8($s1)"?
    a) Immediate addressing
    b) Register addressing
    c) Base or displacement addressing
    d) PC-relative addressing

## Part II: Short Answer Questions (30 points)

1. (10 points) Explain the difference between a structural hazard and a data hazard in pipelined processors. Give one example of each.

2. (10 points) Describe the concept of "forwarding" (or bypassing) in pipeline design. Explain how it helps improve performance and provide a specific scenario where it would be used.

3. (10 points) Define the terms "throughput" and "latency" in the context of pipeline performance. How does pipelining affect each of these metrics?

## Part III: Calculation Problems (30 points)

1. (15 points) Consider two different processor implementations for the same instruction set:
   - Processor A has a clock cycle time of 2 ns and an average CPI of 1.5.
   - Processor B has a clock cycle time of 3 ns and an average CPI of 1.0.
   
   For a program with 1 million instructions:
   a) Calculate the execution time on each processor.
   b) Which processor executes the program faster and by what percentage?
   c) If processor A's CPI could be reduced to 1.2 while maintaining the same clock cycle time, would it outperform processor B? Show your calculations.

2. (15 points) For the following MIPS code:
   ```
   lw $t0, 0($s0)
   add $t1, $t0, $s1
   sub $t2, $t1, $s2
   sw $t2, 4($s0)
   ```
   a) Draw the pipeline execution diagram showing all 5 stages (IF, ID, EX, MEM, WB) for each instruction, considering data hazards and the necessary stalls or forwarding.
   b) Calculate how many clock cycles it would take to execute this code with:
      i. No hazard handling (just stalling)
      ii. With full forwarding

## Part IV: Design Problem (20 points)

1. (20 points) Design a simple datapath for the MIPS "beq" (branch if equal) instruction. Your diagram should:
   a) Show all necessary components (ALU, registers, multiplexers, etc.)
   b) Indicate the control signals required
   c) Explain the flow of data through your design
   d) Describe how the processor determines whether to take the branch or not
   e) Explain how the new PC value is computed when the branch is taken

---

## Bonus Question (5 points)

Explain how the transition from single-core to multi-core architectures relates to the power wall problem. What challenges does parallel programming present that weren't concerns in sequential programming?