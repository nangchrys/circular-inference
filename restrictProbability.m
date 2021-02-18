function restrictedProb = restrictProbability(prob)
    % Sets all probabilities below 0.01 to 0.01 and above 0.99 to 0.99,
    % as models can't handle logits that are too high or too low.
    restrictedProb = min(max(prob, 0.01), 0.99);

end