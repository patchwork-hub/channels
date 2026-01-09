export const formatNumber = (num) => {
    if (num >= 1000) {
      return `${(num / 1000).toFixed(1).replace('.', ',')}k`;
    }
    return num.toString();
  };

export const pluralize = (count, singular, plural) => {
return count === 1 ? singular : plural;
};